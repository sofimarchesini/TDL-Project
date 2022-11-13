defmodule Subasta.SubastaController
    use Subasta.app, :Controllers

    alias Subasta.Subasta

    plug :scrub_params, "subasta" when action in [:create, :update]

    # LISTAR SUBASTAS
    def index(conn, _params) do
      subastas = Subastero.listar_subastas
      render(conn, "index.json", subastas: subastas)
    end

    # CREAR SUBASTA
    def create(conn, %{"subasta" => %{"nombre" => nombre, "precio_base" => precio_base, "duracion" => duracion}}) do
      id_subasta = Subastero.crear_subasta(nombre, precio_base, duracion)
      subasta = Subastero.obtener_subasta(id_subasta)

      if subasta != nil do
        conn
        |> put_status(:created)
        |> render("show.json", subasta: subasta)
      else
        conn
        |> put_status(:unprocessable_entity)
      end
    end

    # OBTENER SUBASTA
    def show(conn, %{"id" => id}) do
      subasta = Subastero.obtener_subasta(id)
      conn
      |> put_status(:ok)
      |> render("show.json", subasta: subasta)
    end

    # CANCELAR SUBASTA
    def delete(conn, %{"id" => id}) do
      Subastero.cancelar_subasta(id)

      send_resp(conn, :no_content, "")
    end
  end
