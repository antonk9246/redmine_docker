module TabularProjectsView
  module Patches


    module ContextMenusControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods

        def projects
          @project = Project.find(params[:ids].shift)

          @can = {:add_issues => User.current.allowed_to?(:add_issues, @project),
                  :manage_versions => (User.current.allowed_to?(:manage_versions, @project)),
                  :edit_project => User.current.allowed_to?(:edit_project, @project),
                  :view_wiki_pages => User.current.allowed_to?(:view_wiki_pages, @project),
                  :comment_news => User.current.allowed_to?(:comment_news, @project),
                  :view_test_cases => User.current.allowed_to?(:view_test_cases, @project),
                  :road_map => User.current.allowed_to?(:view_roadmap, @project),  #roadmap
                  :activity => true,
                  :overview => true,
                  :view_gantt => User.current.allowed_to?(:view_gantt, @project),
                  :view_files => User.current.allowed_to?(:view_files, @project)

          }





          render :layout => false

        end
      end

    end
  end
end

unless ContextMenusController.included_modules.include?(TabularProjectsView::Patches::ContextMenusControllerPatch)
  ContextMenusController.send(:include, TabularProjectsView::Patches::ContextMenusControllerPatch)

end