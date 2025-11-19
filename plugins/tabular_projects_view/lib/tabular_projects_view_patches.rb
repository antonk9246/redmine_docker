#patches
require_relative 'tabular_projects_view/patches/projects_helper_patch'
require_relative 'tabular_projects_view/patches/queries_helper_patch'
require_relative 'tabular_projects_view/patches/projects_controller_patch'
require_relative 'tabular_projects_view/patches/project_patch'
require_relative 'tabular_projects_view/patches/project_query_patch'
require_relative 'tabular_projects_view/patches/context_menus_controller_patch'
# require_relative 'tabular_projects_view/patches/dashboard_controller_patch'
# require_relative 'tabular_projects_view/hooks/views_project_hook'

# Load custom enumerations
require_relative '../app/models/project_priority'
require_relative '../app/models/project_status'

module TabularProjectsViewPatches; end
