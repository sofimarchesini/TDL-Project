defmodule Home.PersistentComprador do
  defmacro __using__(_) do
    quote do
      use GenServer
      alias Subastas.Comprador

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

      def get(server, id_comprador) do
        GenServer.call server, { :get, id_comprador }
      end

      def insert(server, datos_comprador) do
        GenServer.call server, { :insert, datos_comprador }
      end

      def update(server, id_comprador, datos_comprador) do
        GenServer.call server, { :update, id_comprador, datos_comprador }
      end

      def delete(server, id_comprador) do
        GenServer.call server, { :delete, id_comprador }
      end

      def clean(server) do
        GenServer.call server, { :clean }
      end

      # -- Callbacks

      def init(:ok) do
        { :ok, {} }
      end

      def handle_call({ :get_all }, _from, _state) do
        all = Subastas.Repo.all(Comprador)
        allMaps = Enum.map all, fn(it) ->
          datos_comprador = Map.from_struct(it)
          rname = String.to_atom datos_comprador[:rname]
          Map.put datos_comprador, :rname, rname
        end

        { :reply, allMaps, _state }
      end

      def handle_call({ :get_all, ids}, _from, _state) do
        all = Subastas.Repo.all(Comprador)

        allMaps = Enum.map all, fn(it) ->
          datos_comprador = Map.from_struct(it)
          rname = String.to_atom datos_comprador[:rname]
          Map.put datos_comprador, :rname, rname
        end
        requiredIds = Enum.filter allMaps, fn(it) ->
          Enum.member? ids, it[:id]
        end

        { :reply, requiredIds, _state }
      end

      def handle_call({ :get, id_comprador }, _from, _state) do
        struct = Subastas.Repo.get!(Comprador, id_comprador)
        datos_comprador = Map.from_struct(struct)
        rname = String.to_atom datos_comprador[:rname]
        datos_modificados = Map.put datos_comprador, :rname, rname

        { :reply, datos_modificados, _state }
      end

      def handle_call({ :insert, datos_comprador }, _from, _state) do
        rname = datos_comprador[:rname]
        rname_str = Atom.to_string rname
        datos_modificados = Map.put datos_comprador, :rname, rname_str

        changeset = Comprador.changeset(%Comprador{}, datos_modificados)
        { :ok, struct } = Subastas.Repo.insert(changeset)
        result = Map.from_struct struct

        { :reply, result[:id], _state }
      end

      def handle_call({ :update, id_comprador, datos_comprador }, _from, _state) do
        comprador = pSubastas.Repo.get!(Comprador, id_comprador)

        changeset = Comprador.changeset(comprador, datos_comprador)
        Subastas.Repo.update(changeset)

        { :reply, :ok, _state }
      end

      def handle_call({ :delete, id_comprador }, _from, _state) do
        comprador = Subastas.Repo.get!(Comprador, id_comprador)
        Subastas.Repo.delete!(comprador)

        { :reply, :ok, _state }
      end

      def handle_call({ :clean }, _from, _state) do
        all = Subastas.Repo.all(Comprador)
        Enum.each all, fn(it) -> Subastas.Repo.delete!(it) end

        { :reply, :ok, _state }
      end

      defoverridable [init: 1, handle_call: 3, get_all: 1, get_all: 2, get: 2, insert: 2, update: 3, delete: 2, clean: 1]
    end
  end
end
