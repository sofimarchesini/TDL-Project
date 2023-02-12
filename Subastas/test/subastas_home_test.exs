require SubastasHome

# (Solo para Homes InMemory)
 defmodule SubastasHomeTest do
   use ExUnit.Case

   test "insert" do
     {:ok, home} = SubastasHome.start_link

     id = SubastasHome.insert(home, "datos")
     assert SubastasHome.get(home, id) == "datos"
   end

   test "update" do
     {:ok, home} = SubastasHome.start_link

     id = SubastasHome.insert(home, "datos")
     SubastasHome.update(home, id, "datos2")
     assert SubastasHome.get(home, id) == "datos2"
   end

   test "get, when there is no value for that key" do
     {:ok, home} = SubastasHome.start_link

     assert SubastasHome.get(home, 123) == nil
   end

   test "delete" do
     {:ok, home} = SubastasHome.start_link

     id = SubastasHome.insert(home, "datos")
     SubastasHome.delete(home, id)
     assert SubastasHome.get(home, id) == nil
   end

   test "get_all" do
     {:ok, home} = SubastasHome.start_link

     SubastasHome.insert(home, "datos")
     SubastasHome.insert(home, "datos2")

     assert SubastasHome.get_all(home) == ["datos", "datos2"]
   end

   test "get_all/1" do
     {:ok, home} = SubastasHome.start_link

     id1 = SubastasHome.insert(home, "datos")
     id2 = SubastasHome.insert(home, "datos2")
     SubastasHome.insert(home, "datos3")

     assert SubastasHome.get_all(home, [id1, id2]) == ["datos", "datos2"]
   end
 end