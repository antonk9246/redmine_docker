require_dependency 'project'

module RbTuning
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module InstanceMethods
        def permission_approve_time?
          projects_member = project.members.where(user_id: User.current.id).first
          projects_member.nil? ? false : projects_member.roles.map(&:id).include?(RbTuning.approve_role_id)
        end
      end
    end
  end
end

Project.send(:include, RbTuning::Patches::ProjectPatch)
