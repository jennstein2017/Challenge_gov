defmodule ChallengeGov.Emails do
  @moduledoc """
  Container for emails that ChallengeGov sends out
  """

  use Bamboo.Phoenix, view: Web.EmailView

  alias ChallengeGov.Mailer

  def pending_challenge_email(challenge) do
    base_email()
    |> to("team@challenge.gov")
    |> subject("Challenge.gov - Challenge Review Needed")
    |> assign(:challenge, challenge)
    |> render("pending-challenge-email.html")
  end

  def challenge_rejection_email(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Edits Requested: #{challenge.title}")
    |> assign(:challenge, challenge)
    |> assign(:message, challenge.rejection_message)
    |> render("challenge-rejection-email.html")
  end

  def challenge_submission(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Your challenge has been submitted")
    |> assign(:challenge, challenge)
    |> render("challenge_submission.html")
  end

  def challenge_auto_published(user, challenge) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Your challenge has been auto published")
    |> assign(:challenge, challenge)
    |> render("challenge_auto_publish.html")
  end

  def managed_submission_submission(user, _manager, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission-submission-managed.html")
  end

  # might require a change in this email.
  def new_submission_submission(user, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission-submission.html")
  end

  def submission_review(user, phase, submission) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Action needed. New submission notification")
    |> assign(:submission, submission)
    |> assign(:phase, phase)
    |> render("managed-submission-created.html")
  end

  def submission_confirmation(submission) do
    base_email()
    |> to(submission.submitter.email)
    |> subject("Challenge.gov - Submission created for #{submission.challenge.title}")
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> render("submission-confirmation.html")
  end

  def days_deactivation_warning(user, days) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Account will be deactivated in #{days} days")
    |> assign(:days, days)
    |> render("days_deactivation_warning.html")
  end

  def one_day_deactivation_warning(user) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - Account will be deactivated in 1 day")
    |> render("one_day_deactivation_warning.html")
  end

  def contact(poc_email, challenge, public_email, body) do
    base_email()
    |> to(poc_email)
    |> subject("Challenge.gov - #{challenge.title}: Message from Public Visitor")
    |> put_header("Reply-To", public_email)
    |> assign(:public_email, public_email)
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact.html")
  end

  def contact_confirmation(public_email, challenge, body) do
    base_email()
    |> to(public_email)
    |> subject("Challenge.gov - Challenge #{challenge.title}: Contact Confirmation")
    |> assign(:challenge, challenge)
    |> assign(:body, body)
    |> render("contact_confirmation.html")
  end

  def account_activation(user) do
    base_email()
    |> to(user.email)
    |> subject("Challenge.gov - your account has been activated")
    |> render("account_activation.html")
  end

  def submission_invite(submission_invite) do
    base_email()
    |> to(submission_invite.submission.submitter.email)
    |> subject(
      "Challenge.gov - You have been invited to the next phase of #{submission_invite.submission.challenge.title}"
    )
    |> assign(:submission_invite, submission_invite)
    |> assign(:challenge, submission_invite.submission.challenge)
    |> render("submission_invite.html")
  end

  defp base_email() do
    new_email()
    |> from(Mailer.from())
  end
end
