module TabularProjectsView
  module Hooks
    class ViewsProjectHook < Redmine::Hook::ViewListener
      render_on :view_projects_form, :partial => 'hooks/projects/tabular_fields'
    end
  end
end
