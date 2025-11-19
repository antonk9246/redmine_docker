module RbTuning
  module Patches
    module CustomFieldEnumerationsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :enumeration_params_without_rb_tag, :enumeration_params
          alias_method :enumeration_params, :enumeration_params_with_rb_tag
          
          alias_method :update_each_params_without_rb_tag, :update_each_params
          alias_method :update_each_params, :update_each_params_with_rb_tag
        end
      end
      module InstanceMethods
        def enumeration_params_with_rb_tag
          params.require(:custom_field_enumeration).permit(:name, :active, :position, :rb_tag)
        end

        def update_each_params_with_rb_tag          
          params.permit(:custom_field_enumerations => [:name, :active, :position, :rb_tag]).require(:custom_field_enumerations)
        end
      end 
    end
  end
end

CustomFieldEnumerationsController.send(:include, RbTuning::Patches::CustomFieldEnumerationsControllerPatch)