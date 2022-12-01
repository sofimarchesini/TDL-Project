defmodule Subasta.Comprador do
  use Subasta.Web, :model

  schema "compradores" do
    @primary_key { :id, :binary_id, autogenerate: true }

    field :rname, :string
    field :nombre, :string

    timestamps
  end

  @required_fields ~w(rname nombre)
  @optional_fields ~w()

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
