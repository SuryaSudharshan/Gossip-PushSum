defmodule Gossip do
    use GenServer
    def start_link do
      GenServer.start_link(__MODULE__, [])
    end
  
    def propogate_gossip(pid, message, number, topo, numNodes,nodes_arr) do
      GenServer.cast(pid, {:propogate_gossip, message, number, topo, numNodes,nodes_arr})
    end
    def init(messages) do
      {:ok, messages}
    end
  
    def handle_cast({:propogate_gossip, new_message, number, topo, numNodes,nodes_arr}, messages) do
      count=Enum.at(messages,0)
      if count == 9 do
        MasterNode.add_convlist(:global.whereis_name(:"nodeMaster"), number)
      end
      r = MasterNode.get_nonconvlist(:global.whereis_name(:"nodeMaster"), number, topo, numNodes,nodes_arr)
      nodeName = String.to_atom("node#{r}")
      :timer.sleep 1
      Gossip.propogate_gossip(:global.whereis_name(nodeName), new_message, r, topo, numNodes,nodes_arr)
      newx=Enum.at(messages,1)
      newy=Enum.at(messages,2)
      newcount=Enum.at(messages,0)+1
      newstate=[newcount,newx,newy]
      {:noreply, newstate}
    end
    def s(n, b, topo) do
      convlist = MasterNode.get_convlist(:global.whereis_name(:"nodeMaster"))
      bllen = Kernel.length(convlist)
      threshold=
        if (topo == "line" or topo == "rand2D" or topo =="impline" or topo == "full") and n>=100 do
          0.02
        else 
          0.1
        end
      if(bllen / n >= threshold) do
        IO.inspect(bllen/n)
        IO.puts "Time = #{System.system_time(:millisecond) - b}"
        Process.exit(self(),:kill)
      end
      s(n, b, topo)
    end
    def createNodes(times) do
    nodes_info=Enum.reduce((1..times),[],fn(i,nodes_info)->
        x=:rand.uniform(10)/10
        y=:rand.uniform(10)/10
        nodeName = String.to_atom("node#{i}")
        {:ok, pid} = GenServer.start_link(Gossip,[1,x,y], name: nodeName)
        :global.register_name(nodeName,pid)
        [[i, [x,y]] | nodes_info]
      end)
    end
  end
  