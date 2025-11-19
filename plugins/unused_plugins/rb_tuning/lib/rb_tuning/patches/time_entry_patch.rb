require_dependency 'time_entry'

module RbTuning
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          safe_attributes 'approve'
          validate :approve_role_validation
        end
      end

      module InstanceMethods
        def approve_role_validation
          return if new_record?
          approve_role_id = RbTuning.approve_role_id
          old_time_entry_record = TimeEntry.find(self.id)
          if old_time_entry_record.approve && !project.members.where(user_id: User.current.id).first.roles.map(&:id).include?(approve_role_id)
            self.errors[:base] << l(:error_record_approved)
          elsif old_time_entry_record.approve && project.members.where(user_id: User.current.id).first.roles.map(&:id).include?(approve_role_id)
            new_attributes = self.attributes.select{|k,v| k != "approve"}
            old_attributes = old_time_entry_record.attributes.select{|k,v| k != "approve"}
            custom_fields_changed = self.custom_field_values.map { |field| field.value == field.value_was }.include?(false)
            if new_attributes != old_attributes || custom_fields_changed
              self.errors[:base] << l(:error_record_approved)
            end
          end
        end
      end
    end
  end
end

TimeEntry.send(:include, RbTuning::Patches::TimeEntryPatch)
