defmodule MasterNode do
    use GenServer
    def add_convlist(pid, message) do
      GenServer.cast(pid, {:add_convlist, message})
    end
    # def add_convlist(pid) do
    #   GenServer.call(pid, {:add_convlist})
    # end
    def get_convlist(pid) do
      GenServer.call(pid, :get_convlist, :infinity)
    end
  
    def get_nonconvlist(pid, nodeId, topo, numNodes,nodes_arr) do
      GenServer.call(pid, {:get_nonconvlist, nodeId, topo, numNodes,nodes_arr}, :infinity)
    end
  
    def whiteRandom(topo, numNodes, nodeId, messages,nodes_arr) do
      nodeList = Topology.checkRnd(topo, numNodes, nodeId,messages,nodes_arr)
      nodeLen = Kernel.length(nodeList)
      topoCheck = false
      if topo == "line" or topo == "rand2D" do
        topoCheck = true
      end
      r=
        if nodeLen == 0 do
          :timer.sleep 1000
          Process.exit(:global.whereis_name(:"runner"),:kill)
        else
          randomNeighbor = :rand.uniform(nodeLen)
          Enum.at(nodeList, randomNeighbor-1)
      end
    end
    def init(messages) do
      {:ok, messages}
    end
  
    def handle_call(:get_convlist, _from, messages) do
      {:reply, messages, messages}
    end
  
    def handle_cast({:add_convlist, new_message}, messages) do
      {:noreply, [new_message | messages]}
    end
    # def handle_cast({:add_convlist, new_message},_from, messages) do
    #   {:reply,:ok}
    #   Process.exit(_from,:kill)
    # end
    def handle_call({:get_nonconvlist, nodeId, topo, numNodes,nodes_arr}, _from, messages) do
      nodernd = whiteRandom(topo, numNodes, nodeId, messages,nodes_arr)
      {:reply, nodernd, messages}
    end
  
  end
  