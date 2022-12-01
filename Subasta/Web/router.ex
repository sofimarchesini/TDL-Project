defmodule Subasta.Router do
  use Subasta.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Subasta do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/subastas", SubastaController, except: [:new, :edit]
    resources "/ofertas", OfertaController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Subasta do
  #   pipe_through :api
  # end
end
