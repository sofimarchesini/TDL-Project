require Integer
require SubastasHome
require CompradoresHome
require ControladorSubasta
require DateHelper

defmodule SubasteroServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def start(opts \\ []) do
    GenServer.start(__MODULE__, :ok, opts)
  end

  def crear_usuario(server, rname_usuario, nombre) do
    GenServer.call server, { :crear_usuario, rname_usuario, nombre }
  end

  def crear_subasta(server, titulo, precio_actual, duracion) do
    GenServer.call server, { :crear_subasta, titulo, precio_actual, duracion }
  end

  def ofertar(server, id_subasta, id_comprador, oferta) do
    GenServer.call server, { :ofertar, id_subasta, id_comprador, oferta }
  end

  def cancelar_subasta(server, id_subasta) do
    GenServer.call server, { :cancelar_subasta, id_subasta }
  end

  def listar_subastas(server) do
    GenServer.call server, { :listar_subastas }
  end

  def terminar_subasta(server, id_subasta) do
    GenServer.call server, { :terminar_subasta, id_subasta }
  end

  def obtener_subasta(server, id_subasta) do
    GenServer.call server, { :obtener_subasta, id_subasta }
  end

  def ping(server) do
    GenServer.call server, { :ping }
  end

  # ---

  def notificar(interesados, mensaje, get_rname \\ fn(interesado) -> interesado[:rname] end) do
    Enum.each(interesados, fn(interesado) ->
      rname = get_rname.(interesado)

      pid = :global.whereis_name(rname)
      if pid != :undefined do
        send pid, mensaje
      end
    end)
  end

  # ---------- Callbacks ------------

  def init(:ok) do
    IO.puts "El subastero ha sido iniciado"

    { :ok, subastasHome } = SubastasHome.start_link
    { :ok, compradoresHome } = CompradoresHome.start_link
    controladores = %{}

    subastas_activas = SubastasHome.get_all subastasHome
    Enum.each subastas_activas, fn(it) ->
      tiempo_restante = DateHelper.cuanto_falta_para it[:fecha_expiracion]

      if tiempo_restante > 0 do
        nueva_expiracion = DateHelper.fecha_mas it[:fecha_expiracion], 5000
        tiempo_restante = tiempo_restante + 5000
        it = Map.put it, :fecha_expiracion, nueva_expiracion
        SubastasHome.update subastasHome, it[:id], it

        IO.puts "---"
        IO.puts "Encontré en la BD la subasta #{it[:id]} y veo que le faltan #{tiempo_restante}ms. La levanto..."
        IO.puts "---"
        pid_controlador = crear_controlador_subasta(it[:id], tiempo_restante)
        controladores = Map.put(controladores, it[:id], pid_controlador)
      end
    end

    { :ok, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### CREAR USUARIO
  ###
  def handle_call({ :crear_usuario, rname_usuario, nombre }, _from, { subastasHome, compradoresHome, controladores }) do
    datos_comprador =
      %{
        rname: rname_usuario,
        nombre: nombre
      }

    id_usuario = CompradoresHome.insert(compradoresHome, datos_comprador)

    IO.puts "ATENCIÓN! TENEMOS UN NUEVO USUARIO: #{nombre}, #{id_usuario}"

    { :reply, id_usuario, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### CREAR SUBASTA
  ###
  def handle_call({ :crear_subasta, titulo, precio_actual, duracion }, _from, { subastasHome, compradoresHome, controladores }) do
    datos_subasta =
      %{
        titulo: titulo,
        precio_actual: precio_actual,
        fecha_expiracion: DateHelper.ahora_mas(duracion),
        compradores: []
      }

    id_subasta = SubastasHome.insert subastasHome, datos_subasta

    notificar(CompradoresHome.get_all(compradoresHome), { :nueva_subasta, datos_subasta })

    pid_controlador = crear_controlador_subasta(id_subasta, duracion)

    controladores = Map.put(controladores, id_subasta, pid_controlador)

    IO.puts "ATENCIÓN! TENEMOS UNA NUEVA SUBASTA: #{titulo}"

    { :reply, id_subasta, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### OFERTAR
  ###
  def handle_call({ :ofertar, id_subasta, id_comprador, oferta }, _from, { subastasHome, compradoresHome, controladores }) do
    subasta = SubastasHome.get subastasHome, id_subasta
    comprador = CompradoresHome.get(compradoresHome, id_comprador)

    if oferta > subasta[:precio_actual] do
      subasta = Map.put(subasta, :compradores, subasta[:compradores] ++ [id_comprador])

      SubastasHome.update(subastasHome, id_subasta,
        %{
          titulo: subasta[:titulo],
          precio_actual: oferta,
          fecha_expiracion: subasta[:fecha_expiracion],
          id_comprador: id_comprador,
          compradores: subasta[:compradores]
       }
      )
      notificar([comprador], { :ok, "Tu oferta está ganando en #{subasta[:titulo]}"})

      compradores_a_notificar = Enum.reject(CompradoresHome.get_all(compradoresHome), fn(comp) -> comp[:rname] == comprador[:rname] end)

      notificar(
        compradores_a_notificar,
        { :nueva_oferta, "La subasta #{subasta[:titulo]} tiene un nuevo precio: $ #{oferta}"}
      )

      IO.puts "ATENCIÓN! UN USUARIO OFERTÓ EN #{subasta[:titulo]} por $ #{oferta}"
    else
      notificar([comprador], {:ok, "Tu oferta fue insuficiente"})
      IO.puts "ATENCIÓN! UN USUARIO OFERTÓ EN #{subasta[:titulo]} pero fue insuficiente"
    end

    { :reply, :ok, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### CANCELAR SUBASTA
  ###
  def handle_call({ :cancelar_subasta, id_subasta}, _from, { subastasHome, compradoresHome, controladores }) do
    matar_controlador(controladores, id_subasta)

    subasta_a_cancelar = SubastasHome.get subastasHome, id_subasta
    compradores_de_subasta = CompradoresHome.get_all(compradoresHome, subasta_a_cancelar[:compradores])

    notificar(compradores_de_subasta,
      { :subasta_cancelada, "La subasta ha sido cancelada: #{subasta_a_cancelar[:titulo]}"})

    SubastasHome.delete(subastasHome, id_subasta)

    IO.puts "ATENCIÓN! SE HA CANCELADO UNA SUBASTA: #{subasta_a_cancelar[:titulo]}"

    { :reply, :ok, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### TERMINAR SUBASTA
  ###
  def handle_call({ :terminar_subasta, id_subasta }, _from, { subastasHome, compradoresHome, controladores }) do
    IO.puts "ATENCIÓN! TERMINÓ LA SUBASTA #{id_subasta}"

    subasta = SubastasHome.get subastasHome, id_subasta

    IO.inspect subasta

    if subasta[:id_comprador] != nil do
      comprador = CompradoresHome.get(compradoresHome, subasta[:id_comprador])

      notificar([comprador],
        { :subasta_ganada, "Has ganado la subasta: #{subasta[:titulo]}!"})
    end

    ids_perdedores_a_notificar = Enum.reject(subasta[:compradores], fn(id) -> id == subasta[:id_comprador] end)
    perdedores_a_notificar = CompradoresHome.get_all(compradoresHome, ids_perdedores_a_notificar)

    notificar(perdedores_a_notificar,
      { :subasta_perdida, "La subasta ha finalizado y has perdido: #{subasta[:titulo]}"})

    SubastasHome.delete subastasHome, id_subasta

    IO.puts "ATENCIÓN! La subasta #{subasta[:titulo]} terminó con éxito por #{subasta[:precio_actual]}"

    { :reply, :ok, { subastasHome, compradoresHome, controladores } }
  end

  ###
  ### OBTENER SUBASTA
  ###
  def handle_call({:obtener_subasta, id_subasta}, _from, { subastasHome, compradoresHome, controladores }) do
    { :reply, SubastasHome.get(subastasHome, id_subasta), { subastasHome, compradoresHome, controladores }}
  end

  ###
  ### PING
  ###
  def handle_call({:ping}, _from, { subastasHome, compradoresHome, controladores }) do
    { :reply, :pong, { subastasHome, compradoresHome, controladores }}
  end

  ###
  ### PARA DEBUGGEAR...
  ###

  def handle_call({ :listar_subastas }, _from, { subastasHome, compradoresHome, controladores }) do
    subastas = SubastasHome.get_all subastasHome
    { :reply, subastas, { subastasHome, compradoresHome, controladores } }
  end

  def handle_cast({ :matate }, _state) do
    Process.exit(self, :kill)
  end

  # ---------- Helpers ------------

  def crear_controlador_subasta(id_subasta, duracion) do
    parent = self
    spawn fn -> ControladorSubasta.empezar_subasta(parent, id_subasta, duracion) end
  end

  def matar_controlador(controladores, id_subasta) do
    controlador = Map.get(controladores, id_subasta)
    Process.exit(controlador, :kill)
  end
end
