module RbTuning
  module Patches
    module TrackerPatch
      def self.included(base)
        base.send(:remove_const, 'CORE_FIELDS')
        base.send(:remove_const, 'CORE_FIELDS_ALL')
        core_fields = %w( assigned_to_id category_id fixed_version_id parent_issue_id start_date due_date estimated_hours done_ratio description additional_time planned_date deadline_changed ).freeze
        base.send(:const_set, 'CORE_FIELDS', core_fields )
        core_fields_all = (Tracker::CORE_FIELDS_UNDISABLABLE + Tracker::CORE_FIELDS).freeze
        base.send(:const_set, 'CORE_FIELDS_ALL', core_fields_all )
        base.class_eval do
          safe_attributes 'rb_tag'
        end
      end
    end
  end
end

Tracker.send(:include, RbTuning::Patches::TrackerPatch)
