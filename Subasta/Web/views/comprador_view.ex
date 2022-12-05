defmodule IascTpSubastas.CompradorView do
  use IascTpSubastas.Web, :view

  def render("index.json", %{compradores: compradores}) do
    %{data: render_many(compradores, IascTpSubastas.CompradorView, "comprador.json")}
  end

  def render("show.json", %{comprador: comprador}) do
    %{data: render_one(comprador, IascTpSubastas.CompradorView, "comprador.json")}
  end

  def render("comprador.json", %{comprador: comprador}) do
    %{id: comprador.id,
      nombre: comprador.nombre}
  end
end
