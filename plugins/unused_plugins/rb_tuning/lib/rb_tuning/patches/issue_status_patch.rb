module RbTuning
  module Patches
    module IssueStatusPatch
      def self.included(base)
        base.class_eval do
          safe_attributes 'rb_tag'
        end
      end
    end
  end
end

IssueStatus.send(:include, RbTuning::Patches::IssueStatusPatch)