defmodule Subasta.Web do

  def model do
    quote do
      use Ecto.Model

      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Subasta.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 1, from: 2]

      import Subasta.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      use Phoenix.HTML

      import Subasta.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Subasta.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
