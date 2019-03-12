defmodule IdeaPortal.ChallengesTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.Challenges

  describe "submitting a new challenge" do
    test "successfully" do
      user = TestHelpers.create_user()

      {:ok, challenge} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around"
        })

      assert challenge.user_id
    end

    test "with errors" do
      user = TestHelpers.create_user()

      {:error, changeset} =
        Challenges.submit(user, %{
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around"
        })

      assert changeset.errors[:focus_area]
    end

    test "attaching supporting documents" do
      user = TestHelpers.create_user()
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, challenge} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around",
          document_ids: [document.id]
        })

      challenge = Repo.preload(challenge, [:supporting_documents])
      assert length(challenge.supporting_documents) == 1
    end

    test "failure attaching a supporting document" do
      user = TestHelpers.create_user(%{email: "user1@example.com"})
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      user = TestHelpers.create_user(%{email: "user2@example.com"})

      {:error, _changeset} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around",
          document_ids: [document.id]
        })
    end
  end
end
