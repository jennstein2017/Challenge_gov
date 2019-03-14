defmodule Web.AccountController do
  use Web, :controller

  alias IdeaPortal.Accounts

  def edit(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("edit.html")
  end

  def update(conn, %{"user" => params = %{"password" => _password}}) do
    %{current_user: user} = conn.assigns

    case Accounts.update_password(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your account has been updated")
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> redirect(to: Routes.account_path(conn, :edit))
    end
  end

  def update(conn, %{"user" => params}) do
    %{current_user: user} = conn.assigns

    case Accounts.update(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your account has been updated")
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> put_status(422)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
