defmodule Subasta.OfertaController do
  use Subasta.Web, :controller

  alias Subasta.Oferta

  plug :scrub_params, "oferta" when action in [:create]

  def create(conn, %{"id_subasta" => id_subasta, "id_comprador" => id_comprador, "oferta" => oferta}) do
    result = Subastero.ofertar(id_subasta, id_comprador, oferta)

    if oferta != nil do
      conn
      |> put_status(:created)
      |> render("oferta.json", oferta: {result})
    else
      conn
      |> put_status(:unprocessable_entity)
    end
  end
end
