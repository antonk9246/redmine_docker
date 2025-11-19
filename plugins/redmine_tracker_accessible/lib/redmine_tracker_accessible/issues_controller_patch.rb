module RedmineTrackerAccessible
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        helper :extra_access
        include ExtraAccessHelper
      end
    end

    module InstanceMethods
    end
  end
end
