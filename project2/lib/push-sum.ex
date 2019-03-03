defmodule PushSum do
    use GenServer
    def start_link do
      GenServer.start_link(__MODULE__, [])
    end
    def init(messages) do
      {:ok, messages}
    end

    def propogate_pushsum(pid, message, number, topo, numNodes, halfS, halfW,nodes_arr) do
        GenServer.cast(pid, {:propogate_pushsum, message, number, topo, numNodes, halfS, halfW,nodes_arr})
    end
  
    def handle_cast({:propogate_pushsum, new_message, number, topo, numNodes, halfS, halfW,nodes_arr}, messages) do
      newS = Enum.at(messages,3) + halfS
      newW = Enum.at(messages,4) + halfW
      oldRatio = Enum.at(messages,3) / Enum.at(messages,4)
      newRatio = newS / newW
      oldCount = Enum.at(messages,5)
  
      oldCount=
        if abs(oldRatio - newRatio) <= 0.0000000001 do
          if Enum.at(messages,5) >= 2 do
            MasterNode.add_convlist(:global.whereis_name(:"nodeMaster"), number)
          end
          Enum.at(messages,5) + 1
        else
          oldCount
        end
      halfS = newS / 2
      halfW = newW / 2
  
      newS = newS - halfS
      newW = newW - halfW
      filler_1=Enum.at(messages,0)
      filler_2=Enum.at(messages,1)
      filler_3=Enum.at(messages,2)
      newState = [filler_1,filler_2,filler_3,newS, newW, oldCount]
      r = MasterNode.get_nonconvlist(:global.whereis_name(:"nodeMaster"), number, topo, numNodes,nodes_arr)
      nodeName = String.to_atom("node#{r}")
      PushSum.propogate_pushsum(:global.whereis_name(nodeName), new_message, r, topo, numNodes, halfS, halfW,nodes_arr)
      {:noreply, newState}
    end
    def s(n, b, topo) do
      convlist = MasterNode.get_convlist(:global.whereis_name(:"nodeMaster"))
      bllen = Kernel.length(convlist)
      threshold=
        if (topo == "line" or topo == "rand2D" or topo =="impline" or topo == "full") and n>=100 do
          0.009
        else 
          0.1
        end
      # IO.inspect(bllen / n)
      if(bllen / n >= threshold) do
        IO.puts "Time = #{System.system_time(:millisecond) - b}"
        Process.exit(self(),:kill)
      end
      s(n, b, topo)
    end
  
    def createNodes(times) do
      # IO.puts("Inside push-sum nodes")
      # IO.puts(times)
      nodes_info=Enum.reduce((1..times),[],fn(i,nodes_info)->
        x=:rand.uniform(10)/10
        y=:rand.uniform(10)/10
        nodeName = String.to_atom("node#{i}")
        {:ok, pid} = GenServer.start_link(PushSum,[1,x,y,i,1,0], name: nodeName)
        :global.register_name(nodeName,pid)
        [[i, [x,y]] | nodes_info]
      end)
    end
  end