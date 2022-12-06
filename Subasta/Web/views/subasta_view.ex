defmodule Subasta.SubastaView do
  use Subasta.Web, :view

  def render("index.json", %{subastas: subastas}) do
    %{data: render_many(subastas, Subasta.SubastaView, "subasta.json")}
  end

  def render("show.json", %{subasta: subasta}) do
    %{data: render_one(subasta, Subasta.SubastaView, "subasta.json")}
  end

  def render("subasta.json", %{subasta: subasta}) do
    %{id: subasta.id,
      titulo: subasta.titulo,
      precio: subasta.precio_actual,
      fecha_expiracion: subasta.fecha_expiracion}
  end
end
