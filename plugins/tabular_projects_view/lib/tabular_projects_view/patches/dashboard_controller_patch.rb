# module TabularProjectsView
#   module Patches
#     module DashboardControllerPatch
#       def self.included(base)
#         base.class_eval do
#           include QueriesHelper
#           helper :queries
#           before_action :retrieve_project_query, only: [:global, :section_global, :prepare_global_report]
#         end
#       end
#     end
#   end
# end

# unless DashboardController.included_modules.include?(TabularProjectsView::Patches::DashboardControllerPatch)
#   DashboardController.send(:include, TabularProjectsView::Patches::DashboardControllerPatch)
# end
