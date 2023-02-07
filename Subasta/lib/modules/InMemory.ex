defmodule Home.InMemory do
  defmacro __using__(_) do
    quote do
      use GenServer

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
      end

      def start(opts \\ []) do
        GenServer.start(__MODULE__, :ok, opts)
      end

      def get_all(server) do
        GenServer.call server, { :get_all }
      end

      def get_all(server, ids) do
        GenServer.call server, { :get_all, ids }
      end

      def get(server, id) do
        GenServer.call server, { :get, id }
      end

      def insert(server, datos) do
        GenServer.call server, { :insert, datos }
      end

      def update(server, id, datos) do
        GenServer.call server, { :update, id, datos }
      end

      def delete(server, id) do
        GenServer.call server, { :delete, id }
      end

      def clean(server) do
        GenServer.call server, { :clean }
      end

      # -- Callbacks

      def init(:ok) do
        mapa = %{}
        { :ok, mapa }
      end

      def handle_call({ :get_all }, _from, mapa) do
        { :reply, Map.values(mapa), mapa }
      end

      def handle_call({ :get_all, ids}, _from, mapa) do
        { :reply, Map.values(Map.take(mapa, ids)), mapa}
      end

      def handle_call({ :get, id }, _from, mapa) do
        { :reply, Map.get(mapa, id), mapa }
      end

      def handle_call({ :insert, datos }, _from, mapa) do
        id = Integer.to_string :random.uniform(1000000)
        { :reply, id, Map.put(mapa, id, datos) }
      end

      def handle_call({ :update, id, datos }, _from, mapa) do
        { :reply, :ok, Map.put(mapa, id, datos) }
      end

      def handle_call({ :delete, id }, _from, mapa) do
        { :reply, :ok, Map.delete(mapa, id) }
      end

      def handle_call({ :clean }, _from, mapa) do
        { :reply, :ok, %{} }
      end

      defoverridable [init: 1, handle_call: 3, get_all: 1, get_all: 2, get: 2, insert: 2, update: 3, delete: 2, clean: 1]
    end
  end
end
