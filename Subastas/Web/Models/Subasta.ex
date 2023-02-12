defmodule Subastas.Subasta do
  use Subastas.Web, :model

  schema "subastas" do
    @primary_key { :id, :binary_id, autogenerate: true }

    field :titulo, :string
    field :precio_actual, :integer
    field :fecha_expiracion, Timex.Ecto.DateTime
    field :id_comprador, :string
    field :compradores, { :array, :string }

    timestamps
  end

  @required_fields ~w(titulo precio_actual fecha_expiracion)
  @optional_fields ~w(id_comprador compradores)

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
