defmodule Subasta.CompradorView do
  use Subasta.Web, :view

  def render("index.json", %{compradores: compradores}) do
    %{data: render_many(compradores, Subasta.CompradorView, "comprador.json")}
  end

  def render("show.json", %{comprador: comprador}) do
    %{data: render_one(comprador, Subasta.CompradorView, "comprador.json")}
  end

  def render("comprador.json", %{comprador: comprador}) do
    %{id: comprador.id,
      nombre: comprador.nombre}
  end
end
