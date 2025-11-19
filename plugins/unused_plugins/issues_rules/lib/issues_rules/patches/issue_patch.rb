require_dependency 'issue'

module IssuesRules
  module Patches
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          #validate :fin_tracker_validation
          validate :tracker_hierarchy_validation
        end
      end

      module InstanceMethods
        def tracker_hierarchy_validation()

          parent_issue_id = self.parent_issue_id if self.parent_issue_id !=nil 
          Issue.find_by(id: parent_issue_id) ? parent_issue = Issue.find_by(id: parent_issue_id) : parent_issue = nil
          parent_tracker_id = (parent_issue.tracker.id if parent_issue)
          curent_tracker_id = self.tracker.id

          if parent_tracker_id != nil && curent_tracker_id != nil && (RelatedTracker.find_by(parent_id: parent_tracker_id, child_id: curent_tracker_id)).nil?
            self.errors[:base] << l(:error_parent_task_tracker, name: self.tracker.name)
          end
          
          if parent_issue_id.nil? && (RelatedTracker.find_by(parent_id: 0, child_id: curent_tracker_id)).nil?
            self.errors[:base] << l(:error_parent_task_tracker, name: self.tracker.name)
          end


          
        end


        # def fin_tracker_validation 
          
          
        #   current_issues_tracker = self.tracker
        #   fin_tracker_id = Setting.plugin_issues_rules['financial_tracker']
        #   pm_tracker_id = Setting.plugin_issues_rules['pm_tracker']
        #   fin_tracker = Tracker.find(fin_tracker_id) if fin_tracker_id != '' && fin_tracker_id != nil
          
        #   if current_issues_tracker.id == fin_tracker_id.to_i && !parent_issue_id.nil?
        #     self.errors[:base] << l(:error_parent_task_fin_tracker, name: current_issues_tracker.name)
        #   end

        #   if current_issues_tracker.id == pm_tracker_id.to_i
        #     if parent_issue_id.nil? && !self.project.issues.where(parent_id: nil, tracker_id: pm_tracker_id).empty?
        #       self.errors[:base] << l(:error_parent_task_pm_tracker, name: current_issues_tracker.name)
        #     elsif !parent_issue_id.nil?
        #       parent_issue = Issue.find(parent_issue_id)
        #       if parent_issue.tracker_id != pm_tracker_id.to_i
        #         self.errors[:base] << l(:error_parent_task_pm_tracker, name: current_issues_tracker.name)
        #       end
        #     end
        #   end

        #   if fin_tracker && current_issues_tracker.id != fin_tracker.id && current_issues_tracker.id != pm_tracker_id.to_i
        #     self.parent_id = parent_issue_id
        #     unless searcher(self, fin_tracker_id)
        #       self.errors[:base] << l(:error_parent_task_standard_tracker, name: fin_tracker.name)
        #     end
        #   end

        # end

        # def searcher(issue, tracker_id, depth_level = 0)
        #   return false if issue.parent.nil? || depth_level > 16

        #   issue.parent.tracker.id == tracker_id.to_i || searcher(issue.parent, tracker_id, depth_level + 1)
        # end
      end
    end
  end
end

unless Issue.included_modules.include?(IssuesRules::Patches::IssuePatch)
  Issue.send(:include, IssuesRules::Patches::IssuePatch)
end
