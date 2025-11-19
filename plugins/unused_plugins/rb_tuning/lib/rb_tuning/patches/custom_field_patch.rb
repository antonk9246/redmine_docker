module RbTuning
  module Patches
    module CustomFieldPatch
      def self.included(base)
        base.class_eval do
          safe_attributes 'rb_tag'
        end
      end
    end
  end
end

CustomField.send(:include, RbTuning::Patches::CustomFieldPatch)