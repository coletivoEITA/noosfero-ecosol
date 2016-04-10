module WorkAssignmentPlugin::Helper

  include CmsHelper

  def link_to_last_submission(author_folder, user)
    if WorkAssignmentPlugin.can_download_submission?(user, author_folder.children.last)
      link_to(author_folder.name, author_folder.children.last.url)
    else
      author_folder.name
    end
  end

  # FIXME Copied from custom_forms. Consider passing it to core...
  def time_format(time)
    minutes = (time.min == 0) ? '' : ':%M'
    hour = (time.hour == 0 && minutes.blank?) ? '' : ' %H'
    h = hour.blank? ? '' : 'h'
    time.strftime("%Y-%m-%d#{hour+minutes+h}")
  end

  def display_delete_button(article)
    expirable_button article, :delete, _('Delete'),
    {:controller =>'cms', :action => 'destroy', :id => article.id },
    method: :post, 'data-confirm' => delete_article_message(article)
  end

  def display_privacy_button(author_folder, user)
    folder = environment.articles.find_by_id(author_folder.id)
    work_assignment = folder.parent
    @back_to = url_for(work_assignment.url)

    if(user && work_assignment.allow_visibility_edition &&
      ((author_folder.author_id == user.id && (user.is_member_of? profile)) ||
      user.has_permission?('view_private_content', profile)))

      @tokenized_children = prepare_to_token_input(
                            profile.members.includes(:articles_with_access).find_all{ |m|
                              m.articles_with_access.include?(folder)
                            })
      button :edit, _('Edit'), { :controller => 'work_assignment_plugin_myprofile',
      :action => 'edit_visibility', :article_id => folder.id,
      :tokenized_children => @tokenized_children, :back_to => @back_to}, :method => :post
    end
  end
end
