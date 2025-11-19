module RedmineTrackerAccessible
  class Hooks < Redmine::Hook::ViewListener
    include IssuesControllerPatch::InstanceMethods

    # load css files
    def view_layouts_base_html_head(context={})
      if context[:controller] && (context[:controller].is_a?(IssuesController) || context[:controller].is_a?(RolesController))
        stylesheet_link_tag("tracker_accessible.css", :plugin => "redmine_tracker_accessible", :media => "screen")
      else
        ''
      end
    end

    def view_issues_sidebar_queries_bottom(context={})
      if context[:controller].controller_name == 'issues' && context[:controller].action_name == 'show'
        @issue = context[:issue]
        @project = context[:project]

        context[:controller].send(:render, { :partial => "extra_issue_access/siderbar_for_extra_access" })
      else
        ''
      end
    end
  end
end
