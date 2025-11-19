require 'rb_tuning/view_hooks/issue_hooks'
require 'rb_tuning/view_hooks/time_entry_hooks'
require 'rb_tuning/view_hooks/custom_fields_hooks'
require 'rb_tuning/hooks/controller_issue_hook'
require 'rb_tuning/patches/tracker_patch'
require 'rb_tuning/patches/issue_query_patch'
require 'rb_tuning/patches/time_entry_query_patch'
require 'rb_tuning/patches/time_entry_patch'
require 'rb_tuning/patches/project_patch'
require 'rb_tuning/patches/issue_status_patch'
require 'rb_tuning/patches/custom_field_patch'
require 'rb_tuning/patches/custom_field_enumerations_controller_patch'

module RbTuning
  class << self
    def approve_role_id
      Setting.plugin_rb_tuning['approve_role_id'].to_i
    end
  end
end