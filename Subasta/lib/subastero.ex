defmodule Subastero do
  def listar_subastas do
    SubasteroServer.listar_subastas({:global, GlobalSubastero})
  end


  def crear_subasta(titulo, precio_actual, duracion) do
    SubasteroServer.crear_subasta({:global, GlobalSubastero}, titulo, precio_actual, duracion)
  end

  def ofertar(id_subasta, id_comprador, oferta) do
    SubasteroServer.ofertar({:global, GlobalSubastero}, id_subasta, id_comprador, oferta)
  end

  def cancelar_subasta(id_subasta) do
    SubasteroServer.cancelar_subasta({:global, GlobalSubastero}, id_subasta)
  end

  def obtener_subasta(id_subasta) do
    SubasteroServer.obtener_subasta({:global, GlobalSubastero}, id_subasta)
  end

  # Not accessible for http api
  def crear_usuario(rname, nombre) do
    SubasteroServer.crear_usuario({:global, GlobalSubastero}, rname, nombre)
  end
end
