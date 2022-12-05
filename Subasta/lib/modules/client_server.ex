defmodule ClientServer do
  def start(nombre, nodo, pid) do
    server = System.get_env("server")
    rname = :"#{nombre}"
    :global.register_name(rname, pid)

    crear_usuario = fn ->
      Subastero.crear_usuario(rname, "#{nombre}")
    end

    Node.spawn(:"#{server}", crear_usuario)
    IO.puts("Connected. Listenning...")

    listen(nodo, pid)
  end

  def listen(nodo, pid) do
    receive do
      {:nueva_subasta, subasta} ->
        IO.puts("Nueva subasta: #{subasta[:titulo]}. Precio base: $#{subasta[:precio_actual]}.")

      {:ok, mensaje} ->
        IO.inspect(mensaje)

      {:nueva_oferta, mensaje} ->
        IO.inspect(mensaje)

      {:subasta_cancelada, mensaje} ->
        IO.inspect(mensaje)

      {:subasta_ganada, mensaje} ->
        IO.inspect(mensaje)

      {:subasta_perdida, mensaje} ->
        IO.inspect(mensaje)

      _ ->
        IO.puts("No entiendo el mensaje")
    end

    listen(nodo, pid)
  end
end
