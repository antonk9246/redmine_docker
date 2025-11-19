module RbTuning
  module Hooks
    class ControllerIssueHook < Redmine::Hook::ViewListener

      def controller_issues_edit_before_save(context={})
        issue = context[:issue]
        issue.additional_time = context[:params][:issue][:additional_time]
        if issue.planned_date.nil? || context[:params][:issue][:planned_date] != issue.planned_date.strftime("%Y-%m-%d")
          issue.planned_date = context[:params][:issue][:planned_date]
          issue.deadline_changed = DateTime.now if context[:params][:issue][:planned_date] != ''
        end
      end

      def controller_issues_new_before_save(context={})
        issue = context[:issue]
        issue.additional_time = context[:params][:issue][:additional_time]
        issue.planned_date = context[:params][:issue][:planned_date]
        issue.deadline_changed = context[:params][:issue][:deadline_changed]
      end
    end
  end
end