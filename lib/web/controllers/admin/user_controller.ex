defmodule Web.Admin.UserController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Security

  plug(Web.Plugs.FetchPage when action in [:index, :create])

  def index(conn, params) do
    %{current_user: current_user} = conn.assigns

    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "user", %{})
    sort = Map.get(params, "sort", %{})
    %{page: users, pagination: pagination} = Accounts.all(filter: filter, page: page, per: per)

    conn
    |> assign(:user, current_user)
    |> assign(:current_user, current_user)
    |> assign(:users, users)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> assign(:pagination, pagination)
    |> assign(:changeset, Accounts.new())
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.get(id) do
      conn
      |> assign(:current_user, current_user)
      |> assign(:user, user)
      |> render("show.html")
    end
  end

  def create(conn, %{"user" => %{"email" => email, "email_confirmation" => _} = user_params}) do
    %{current_user: originator} = conn.assigns

    with {:error, :not_found} <- Accounts.get_by_email(email),
         {:ok, _} <- Accounts.create(user_params, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User has been added!")
      |> redirect(to: Routes.admin_user_path(conn, :index))
    else
      {:ok, user} ->
        {:ok, user}

        conn
        |> put_flash(:error, "A user with that email already exists")
        |> redirect(to: Routes.admin_user_path(conn, :index))

      {:error, changeset} ->
        %{current_user: current_user} = conn.assigns

        %{page: page, per: per} = conn.assigns
        %{page: users, pagination: pagination} = Accounts.all(page: page, per: per)

        conn
        |> assign(:changeset, changeset)
        |> assign(:current_user, current_user)
        |> assign(:users, users)
        |> assign(:filter, %{})
        |> assign(:pagination, pagination)
        |> render("index.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.get(id) do
      conn
      |> assign(:current_user, current_user)
      |> assign(:user, user)
      |> assign(:changeset, Accounts.edit(user))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "user" => params}) do
    {:ok, user} = Accounts.get(id)

    case Accounts.update(user, params) do
      {:ok, user} ->
        conn
        |> assign(:user, user)
        |> render("show.html")

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def toggle(conn, %{"id" => id, "action" => "activate"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.activate(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User activated")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "suspend"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.suspend(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User suspended")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "revoke"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.revoke(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User revoked")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  # This will likely need to change to take into account the certification, or be part of the certification flow
  # for a user whose account had been decertified either manually or automatically.
  def restore_challenge_access(conn, %{"user_id" => user_id, "challenge_id" => challenge_id}) do
    with {:ok, user} <- Accounts.get(user_id),
         {:ok, challenge} <- Challenges.get(challenge_id),
         _ <- Challenges.restore_access(user, challenge) do
      conn
      |> put_flash(:info, "Challenge access restored")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  # Admin can see the certification that will expire, and create a new one,
  # as they are asserting that the user has the need to continue their access
  # to the system and their assigned challenges
end
