defmodule PrimWeb.ShowLive do
  @moduledoc """
  Shows the actual maximum calculated prime number.
  """
  use PrimWeb, :live_view

  def render(assigns) do
    ~H"""
    <div style="font-size: 25em;">
      <%= @prime %>
    </div>
    """
  end

  def mount(_params, %{}, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Prim.PubSub, "new_prime")

    prime = "-"
    {:ok, assign(socket, :prime, prime)}
  end

  def handle_info({:update, n}, socket) do
    {:noreply, assign(socket, :prime, n)}
  end
end
