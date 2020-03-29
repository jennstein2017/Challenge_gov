defmodule ChallengeGov.SecurityLogs.SecurityLog do
  @moduledoc """
  Security Log schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User

  @type t :: %__MODULE__{}

  @actions [
    "status_change",
    "accessed_site",
    "session_duration"
  ]

  schema "security_log" do
    belongs_to(:originator, User)
    field(:action, :string)
    field(:details, :map)
    field(:originator_role, :string)
    field(:originator_identifyer, :string)
    field(:target_id, :integer)
    field(:target_type, :string)
    field(:target_identifyer, :string)
    field(:logged_at, :utc_datetime)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :action,
      :details,
      :originator_id,
      :originator_role,
      :originator_identifyer,
      :target_id,
      :target_type,
      :target_identifyer
    ])
    |> put_change(:logged_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_inclusion(:action, @actions)
    |> unique_constraint(:originator_id)
  end

  def actions, do: @actions
end
