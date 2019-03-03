defmodule Project2 do
  def main(args) do
    b = System.system_time(:millisecond)
    :global.register_name(:"runner",self())
    topo = Enum.at(args,1)
    numNodes = String.to_integer(Enum.at(args,0))
    algorithm = Enum.at(args,2)
    numNodes=
      if topo == "rand2D" do
        sqrt = :math.sqrt(numNodes) |> Float.ceil |> round |> :math.pow(2) |> round
      else
        numNodes
    end
    IO.puts(numNodes)
    initialNode = :rand.uniform(numNodes-1)
    if algorithm == "gossip" do
      nodes_arr=Gossip.createNodes(numNodes)
      {:ok, pid1} = GenServer.start_link(MasterNode, [], name: :"nodeMaster")
      :global.register_name(:"nodeMaster",pid1)
      :global.sync()
      nodeName = String.to_atom("node#{initialNode}")
      Gossip.propogate_gossip(:global.whereis_name(nodeName), "Gossip", initialNode, topo, numNodes,nodes_arr)
      Gossip.s(numNodes, b, topo)
    end
    if algorithm == "push-sum" do
      nodes_arr=PushSum.createNodes(numNodes)
      {:ok, pid1} = GenServer.start_link(MasterNode, [], name: :"nodeMaster")
      :global.register_name(:"nodeMaster",pid1)
      :global.sync()
      nodeName = String.to_atom("node#{initialNode}")
      PushSum.propogate_pushsum(:global.whereis_name(nodeName), "Push-Sum", initialNode, topo, numNodes, initialNode/2, 0.5,nodes_arr)
      PushSum.s(numNodes, b, topo)
    end
  end
end