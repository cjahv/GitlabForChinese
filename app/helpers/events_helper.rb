module EventsHelper
  ICON_NAMES_BY_EVENT_TYPE = {
    'pushed to' => 'icon_commit',
    'pushed new' => 'icon_commit',
    'created' => 'icon_status_open',
    'opened' => 'icon_status_open',
    'closed' => 'icon_status_closed',
    'accepted' => 'icon_code_fork',
    'commented on' => 'icon_comment_o',
    'deleted' => 'icon_trash_o'
  }.freeze

  def link_to_author(event, self_added: false)
    author = event.author

    if author
      name = self_added ? '您' : author.name
      link_to name, user_path(author.username), title: name
    else
      event.author_name
    end
  end

  def event_action_name(event)
    target =  if event.target_type
                if event.note?
                  event.note_target_type
                else
                  event.target_type.titleize.downcase
                end
              else
                '项目'
              end

    [event.action_name, target].join(" ")
  end

  def event_filter_link(key, tooltip)
    key = key.to_s
    active = 'active' if @event_filter.active?(key)
    link_opts = {
      class: "event-filter-link",
      id:    "#{key}_event_filter",
      title: "#{tooltip.downcase} 过滤",
    }

    content_tag :li, class: active do
      link_to request.path, link_opts do
        content_tag(:span, ' ' + tooltip)
      end
    end
  end

  def event_filter_visible(feature_key)
    return true unless @project

    @project.feature_available?(feature_key, current_user)
  end

  def comments_visible?
    event_filter_visible(:repository) ||
      event_filter_visible(:merge_requests) ||
      event_filter_visible(:issues)
  end

  def event_preposition(event)
    "的"
  end

  def event_feed_title(event)
    words = []
    words << event.author_name
    words << event_action_name(event)

    if event.push?
      words << "的"
      words << event.ref_type
      words << event.ref_name
    elsif event.commented?
      words << "的"
      words << event.note_target_reference
    elsif event.milestone?
      words << "的"
      words << "##{event.target_iid}" if event.target_iid
    elsif event.target
      words << "的"
      words << "##{event.target_iid}："
      words << event.target.title if event.target.respond_to?(:title)
    end

    words.join(" ")
  end

  def event_feed_url(event)
    if event.issue?
      namespace_project_issue_url(event.project.namespace, event.project,
                                  event.issue)
    elsif event.merge_request?
      namespace_project_merge_request_url(event.project.namespace,
                                          event.project, event.merge_request)
    elsif event.commit_note?
      namespace_project_commit_url(event.project.namespace, event.project,
                                   event.note_target)
    elsif event.note?
      if event.note_target
        event_note_target_path(event)
      end
    elsif event.push?
      push_event_feed_url(event)
    end
  end

  def push_event_feed_url(event)
    if event.push_with_commits? && event.md_ref?
      if event.commits_count > 1
        namespace_project_compare_url(event.project.namespace, event.project,
                                      from: event.commit_from, to:
                                      event.commit_to)
      else
        namespace_project_commit_url(event.project.namespace, event.project,
                                     id: event.commit_to)
      end
    else
      namespace_project_commits_url(event.project.namespace, event.project,
                                    event.ref_name)
    end
  end

  def event_feed_summary(event)
    if event.issue?
      render "events/event_issue", issue: event.issue
    elsif event.push?
      render "events/event_push", event: event
    elsif event.merge_request?
      render "events/event_merge_request", merge_request: event.merge_request
    elsif event.note?
      render "events/event_note", note: event.note
    end
  end

  def event_note_target_path(event)
    if event.commit_note?
      namespace_project_commit_path(event.project.namespace,
                                    event.project,
                                    event.note_target,
                                    anchor: dom_id(event.target))
    elsif event.project_snippet_note?
      namespace_project_snippet_path(event.project.namespace,
                                     event.project,
                                     event.note_target,
                                     anchor: dom_id(event.target))
    else
      polymorphic_path([event.project.namespace.becomes(Namespace),
                        event.project, event.note_target],
                        anchor: dom_id(event.target))
    end
  end

  def event_note_title_html(event)
    if event.note_target
      link_to(event_note_target_path(event), title: event.target_title, class: 'has-tooltip') do
        "#{event.note_target_type} #{event.note_target_reference}"
      end
    else
      content_tag(:strong, '(已删除)')
    end
  end

  def event_note(text, options = {})
    text = first_line_in_markdown(text, 150, options)

    sanitize(
      text,
      tags: %w(a img gl-emoji b pre code p span),
      attributes: Rails::Html::WhiteListSanitizer.allowed_attributes + ['style', 'data-name', 'data-unicode-version']
    )
  end

  def event_commit_title(message)
    (message.split("\n").first || "").truncate(70)
  rescue
    "--broken encoding"
  end

  def event_row_class(event)
    if event.body?
      "event-block"
    else
      "event-inline"
    end
  end

  def icon_for_event(note)
    icon_name = ICON_NAMES_BY_EVENT_TYPE[note]
    custom_icon(icon_name) if icon_name
  end

  def icon_for_profile_event(event)
    if current_path?('users#show')
      content_tag :div, class: "system-note-image #{event.action_name.parameterize}-icon" do
        icon_for_event(event.action_name)
      end
    else
      content_tag :div, class: 'system-note-image user-avatar' do
        author_avatar(event, size: 32)
      end
    end
  end
end
