defmodule Web.DashboardView do
  use Web, :view

  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Accounts
  alias ChallengeGov.MessageContextStatuses
  alias Web.Endpoint

  def recertification_warning(conn, user) do
    case CertificationLogs.get_current_certification(user) do
      {:ok, certification} ->
        expiration = Timex.to_unix(certification.expires_at)
        two_weeks_from_now = Timex.to_unix(Timex.shift(Timex.now(), days: 14))

        if expiration < two_weeks_from_now do
          [
            content_tag(
              :span,
              "Your account certification will expire on
                #{certification.expires_at.month}/#{certification.expires_at.day}/#{certification.expires_at.year}",
              class: "mx-2"
            ),
            recertification_action(conn, user)
          ]
        end

      {:error, :no_log_found} ->
        nil
    end
  end

  def recertification_action(conn, user) do
    if user.renewal_request == "certification" do
      [
        content_tag(:span, "Recertification requested", class: "text-primary")
      ]
    else
      [
        link("Request recertification",
          to: Routes.access_path(conn, :recertification),
          target: "",
          class: "btn btn-primary"
        )
      ]
    end
  end

  def dashboard_header(user) do
    wrapper_classes = "col pl-4 pt-5"

    cond do
      Accounts.has_admin_access?(user) ->
        admin_header(wrapper_classes)

      Accounts.is_challenge_manager?(user) ->
        challenge_manager_header(wrapper_classes)

      Accounts.is_solver?(user) ->
        solver_header(wrapper_classes)

      true ->
        content_tag(:div, "")
    end
  end

  defp admin_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h3, "Welcome to the Challenge.Gov portal"),
        content_tag(:p, "Engage with the features below to manage your workflows.", class: "p-0")
      ]
    end
  end

  defp challenge_manager_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h3, "Welcome to the Challenge.gov portal."),
        content_tag(:p, "Engage with the features below to manage your workflows.")
      ]
    end
  end

  defp solver_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h3, "Welcome to the Challenge.gov submission portal."),
        content_tag(
          :p,
          "Use the features below to engage with challenges and manage your submissions."
        )
      ]
    end
  end

  def dashboard_card_links(user) do
    cond do
      Accounts.has_admin_access?(user) ->
        admin_card_links()

      Accounts.is_challenge_manager?(user) ->
        challenge_manager_card_links()

      Accounts.is_solver?(user) ->
        solver_card_links(user)

      true ->
        content_tag(:div, "")
    end
  end

  defp render_solver_message_center_link(user) do
    if MessageContextStatuses.has_messages?(user) do
      render("_card_link.html",
        to: Routes.message_context_path(Endpoint, :index),
        target: "",
        icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-envelope"),
        title: "Message Center",
        description: "View and send messages to Challenge.Gov users."
      )
    else
      []
    end
  end

  defp admin_card_links() do
    [
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.user_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-users"),
            title: "User management",
            description: "View and edit user roles, permissions, and activities on the platform."
          ),
          render("_card_link.html",
            to: Routes.challenge_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-award"),
            title: "Challenge management",
            description: "Manage and view all open and archived challenges."
          )
        ]
      end,
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.message_context_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-envelope"),
            title: "Message center",
            description: "View and send messages to Challenge.Gov users."
          ),
          render("_card_link.html",
            to: Routes.analytics_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-chart-bar"),
            title: "Analytics",
            description: "View web analytics related to your challenges."
          )
        ]
      end,
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.site_content_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-list-alt"),
            title: "Site management",
            description: "Manage content and perform site management tasks."
          )
        ]
      end
    ]
  end

  defp challenge_manager_card_links() do
    [
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.challenge_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-award"),
            title: "Challenge management",
            description: "Manage and view all open and archived challenges."
          ),
          render("_card_link.html",
            to: Routes.challenge_path(Endpoint, :new),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-plus"),
            title: "Create a new challenge",
            description: nil
          )
        ]
      end,
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.message_context_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-envelope"),
            title: "Message center",
            description: "View and send messages to Challenge.Gov users."
          ),
          render("_card_link.html",
            to: Routes.analytics_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-chart-bar"),
            title: "Analytics",
            description: "View web analytics related to your challenges."
          )
        ]
      end,
      content_tag :div, class: "row" do
        [
          render("_card_link.html",
            to: Routes.help_path(Endpoint, :index),
            target: "",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-question-circle"),
            title: "Help",
            description: "Help Center"
          ),
          render("_card_link.html",
            to: Routes.static_path(Endpoint, "/pdfs/prize_and_challenge_toolkit.pdf"),
            target: "_blank",
            icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-tools"),
            title: "Agency toolkit",
            description: "View the Prizes and Challenges Toolkit to learn more."
          )
        ]
      end
    ]
  end

  defp solver_card_links(user) do
    content_tag :div, class: "row" do
      [
        render("_card_link.html",
          to: Routes.submission_path(Endpoint, :index),
          target: "",
          icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-file-alt"),
          title: "My submissions",
          description: "View my challenges submissions."
        ),
        render("_card_link.html",
          to: Routes.saved_challenge_path(Endpoint, :index),
          target: "",
          icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-bookmark"),
          title: "My saved challenges",
          description: "View challenges you've saved and click for challenge details."
        ),
        render_solver_message_center_link(user),
        render("_card_link.html",
          to: Routes.help_path(Endpoint, :solver_index),
          target: "",
          icon: content_tag(:i, "", class: "dashboard-card-icon fas fa-question-circle"),
          title: "Help",
          description: "Help Center"
        )
      ]
    end
  end
end
