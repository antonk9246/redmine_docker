module RbTuning
  module ViewHooks
    class IssueHooks  < Redmine::Hook::ViewListener
      render_on( :view_issues_form_details_bottom, :partial => 'issues/edit_additional_fields')
      render_on( :view_issues_show_details_bottom, :partial => 'issues/show_additional_fields')
    end
  end
end