require_dependency 'time_entry'

module IssuesRules
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          validate :time_log_validation
        end
      end

      module InstanceMethods
        def time_log_validation
          issue_tracker = issue.tracker

          if !issue_tracker.writeoff_f
            self.errors[:base] << l(:error_time_entry_task_tracker)
          end
        end
      end
    end
  end
end

unless TimeEntry.included_modules.include?(IssuesRules::Patches::TimeEntryPatch)
  TimeEntry.send(:include, IssuesRules::Patches::TimeEntryPatch)
end