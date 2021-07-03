defmodule Web.MessageContextStatusControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end

  describe "archive" do
    test "success", %{conn: conn} do
      %{
        challenge_owner_message_context_status: challenge_owner_message_context_status,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :archive,
            challenge_owner_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread archived"
      assert html_response(conn, 302)
    end
  end

  describe "unarchive" do
    test "success", %{conn: conn} do
      %{
        challenge_owner_message_context_status: challenge_owner_message_context_status,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      conn =
        post(
          conn,
          Routes.message_context_status_path(
            conn,
            :unarchive,
            challenge_owner_message_context_status.id
          )
        )

      assert get_flash(conn, :info) == "Message thread unarchived"
      assert html_response(conn, 302)
    end
  end
end
