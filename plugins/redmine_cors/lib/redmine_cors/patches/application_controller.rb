module RedmineCors
  module Patches
    module ApplicationControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_action :cors_set_access_control_headers
        end
      end

      module InstanceMethods
        def cors_set_access_control_headers
          headers['Access-Control-Allow-Origin'] = Setting.plugin_redmine_cors["cors_domain"].to_s
          headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, PUT, DELETE'
          headers['Access-Control-Max-Age'] = "1728000"
          headers['Accept-Ranges'] = 'bytes'
        end
      end
    end
  end
end
