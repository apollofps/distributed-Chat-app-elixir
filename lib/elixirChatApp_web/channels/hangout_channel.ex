defmodule ElixirChatAppWeb.HangoutChannel do
  use ElixirChatAppWeb, :channel

  @impl true
  def join("hangout:lobby", _payload, socket) do
    send self(), :after_join
    {:ok, socket}
###    if authorized?(payload) do
###      {:ok, socket}
###    else
###      {:error, %{reason: "unauthorized"}}
###    end

  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end



  @impl true
  def handle_in("shout", payload, socket) do
    chat_changeset = ElixirChatApp.Accounts.Chat.changeset(%ElixirChatApp.Accounts.Chat{}, payload)
    ElixirChatApp.Repo.insert(chat_changeset)
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    ElixirChatApp.Repo.all(ElixirChatApp.Accounts.Chat)
    |> Enum.each(fn msg -> push(socket, "shout", %{
        name: msg.name,
        message: msg.message,
    }) end)
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end


end
