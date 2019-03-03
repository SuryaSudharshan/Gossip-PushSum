defmodule Topology do
    def select_topology(topology, n, l,messages,nodes_arr) do
        max = n
        cond do
            topology == "line" ->
                cond do
                    l == 1 -> neighbor = [2]
                    l == max -> neighbor = [l-1]
                    true -> neighbor = [l+1, l-1]
                    # IO.inspect(neighbor)    
                end
            topology == "impline" ->
                cond do
                  l == 1 ->
                    neigh_list = Enum.to_list(1..max)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != 1 == true end)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != l+1 == true end)
                    len=Kernel.length(neigh_list)
                    randomNeighbor= :rand.uniform(len)
                    neighbor = [2, Enum.at(neigh_list,randomNeighbor-1)]
                  l == max ->
                    neigh_list = Enum.to_list(1..max)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != max == true end)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != l-1 == true end)
                    len=Kernel.length(neigh_list)
                    randomNeighbor= :rand.uniform(len)
                    neighbor = [l-1, Enum.at(neigh_list,randomNeighbor-1)]
                  true ->
                    neigh_list = Enum.to_list(1..max)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != l == true end)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != l-1 == true end)
                    neigh_list = Enum.filter(neigh_list, fn(x) -> x != l+1 == true end)
                    len=Kernel.length(neigh_list)
                    randomNeighbor= :rand.uniform(len)
                    neighbor = [l-1,l+1, Enum.at(neigh_list,randomNeighbor-1)]
                end
            topology == "full" -> neighbor=Enum.to_list(1..max)

            topology == "rand2D" ->
                current_node = Enum.filter(nodes_arr, fn(i) -> Enum.at(i,0) == l == true end)
                nodes_arr = Enum.filter(nodes_arr, fn(x) -> Enum.at(x,0) != l == true end)
                x=Enum.at(Enum.at(Enum.at(current_node,0),1),0)
                y=Enum.at(Enum.at(Enum.at(current_node,0),1),1)
                neighbor=
                  Enum.reduce((0..n-2),[],fn(i,neighbor)->
                    ind_node=Enum.at(nodes_arr,i)
                    potential_neighbor=Enum.at(ind_node,0)
                    coord=Enum.at(ind_node,1)
                    x1=Enum.at(coord,0)
                    y1=Enum.at(coord,1)
                    neighbor=if (x == x1 and abs(y-y1) <= 0.15) or (y == y1 and abs(x-x1) <= 0.15) do
                      [potential_neighbor|neighbor]
                    else
                      neighbor
                    end
                  end
                  )
            true -> "Select a valid topology"
        end
    end

    def checkRnd(topology, n, l,messages,nodes_arr) do
        nodeList = select_topology(topology, n, l,messages,nodes_arr)
        nodeList = Enum.filter(nodeList, fn(x) -> x != l == true end)
        nodeList = Enum.filter(nodeList, fn(x) -> x != 0 == true end)
        nodeList = Enum.filter(nodeList, fn(x) -> x <= n == true end)
        nodeList = Enum.uniq(nodeList)
        nodeList
    end
end