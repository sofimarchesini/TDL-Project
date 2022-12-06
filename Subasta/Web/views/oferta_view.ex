defmodule Subasta.OfertaView do
  use Subasta.Web, :view

  def render("oferta.json", %{oferta: {id_oferta}}) do
    id_oferta
  end
end
