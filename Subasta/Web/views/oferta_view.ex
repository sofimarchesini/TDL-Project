defmodule IascTpSubastas.OfertaView do
  use IascTpSubastas.Web, :view

  def render("oferta.json", %{oferta: {id_oferta}}) do
    id_oferta
  end
end
