module TabularProjectsView
  module Patches
    module ProjectPatch

      VALID_TASK_TYPES = ['task_based', 'hourly_based'].freeze

      TASK_TYPES = {
        task_based: 'Позадачный',
        hourly_based: 'Почасовой'
      }.freeze

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
        base.send(:include, Redmine::I18n)
        

        base.class_eval do
          unloadable
          
          has_and_belongs_to_many :users
          has_many :lpr_users, -> { where(lpr: true) }, through: :users, source: :client
          
          has_many :project_work_assignments
          has_many :assigned_work_types, through: :project_work_assignments, 
          source: :workable, source_type: 'WorkType'
          has_many :assigned_work_groups, through: :project_work_assignments, 
          source: :workable, source_type: 'WorkGroup'
          
          safe_attributes 'enum_priority_id', 'enum_status_id', 'work_days_per_week', 'downtime_rate_per_hour', 'rate_per_day', 'weekday_rate', 'weekend_rate', 'task_type', 'custom_id', 'daily_time_limit'
          
          before_validation :set_identifier, if: -> { identifier.blank? }

          validates :daily_time_limit, numericality: { greater_than: 0, less_than_or_equal_to: 24 }

          validates :work_days_per_week, numericality: { 
                                          only_integer: true, 
                                          greater_than_or_equal_to: 1, 
                                          less_than_or_equal_to: 7 
                                        }

          validates :downtime_rate_per_hour, :weekday_rate, :weekend_rate, 
          numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

          validates :task_type, 
            inclusion: { in: VALID_TASK_TYPES, 
                         message: "%{value} не является допустимым типом задачи" }
                         
          validates :custom_id, 
                    presence: true,
                    format: { with: /\A[1-9]\d*\z/, message: "должен быть положительным числом" },
                    uniqueness: true
                    
          def custom_id_int
            custom_id.to_i if custom_id.present?
          end
          
          after_save :update_work_assignments_units, if: :saved_change_to_task_type?

          private 

          def set_identifier
            return if name.blank?
            
            ident = name.parameterize.underscore.downcase
            ident = ident.gsub(/[^a-z0-9_]/, '_')
            ident = "p_#{ident}" if ident.match(/^\d/)
            
            max_length = defined?(::Project::IDENTIFIER_MAX_LENGTH) ? ::Project::IDENTIFIER_MAX_LENGTH : 100
            ident = ident[0..max_length-1]
            
            self.identifier = unique_identifier(ident)
          end
          
          def unique_identifier(base)
            return base unless Project.where(identifier: base).exists?
            
            counter = 1
            while counter < 1000
              candidate = "#{base}_#{counter}"
              return candidate unless Project.where(identifier: candidate).exists?
              counter += 1
            end
            
            "#{base}_#{Time.now.to_i}"
          end
        end
      end

      module InstanceMethods
        def humanize_status
          val = case status
                when 1
                  l(:project_status_active)
                when 5
                  l(:project_status_closed)
                when 9
                  l(:project_status_archived)
                else
                  ''
                end

          val.capitalize
        end

        def allowed_children(projects)
          @allowed_children ||= children.select{|child| child.visible? && projects.include?(child)}
        end

        def next_roadmap_due_date
           version = self.versions.order(:effective_date).last
           version.effective_date if version
        end

        def nonconformities
          Nonconformity.where(issue_id: self.issues.pluck(:id))
        end
        
        def work_groups
          WorkGroup.joins(:project_work_assignments)
                  .where(project_work_assignments: { project_id: id })
                  .distinct
        end

        def task_based?
          task_type == 'task_based'
        end
        
        def hourly_based?
          task_type == 'hourly_based'
        end

        def hourly_unit
          if Setting.plugin_redmine_dnb[:hourly_unit_id]
            @hourly_unit ||= Unit.find(Setting.plugin_redmine_dnb[:hourly_unit_id])
          end
        end

        def client
          Client.joins(users: { members: :project }).where(projects: { id: id }).distinct.first
        end

        private

        def update_work_assignments_units
          if hourly_based? && hourly_unit
            project_work_assignments.update_all(unit_id: hourly_unit.id)
          else
            project_work_assignments.includes(:workable).find_each do |assignment|
              unit_id = assignment.workable&.unit_id
              assignment.update_column(:unit_id, unit_id) if unit_id
            end
          end
        end
      end

      module ClassMethods
        def available_scopes
          %W(crm not_helpdesk)
        end
      end
    end
  end
end
unless Project.included_modules.include?(TabularProjectsView::Patches::ProjectPatch)
  Project.send :include, TabularProjectsView::Patches::ProjectPatch
end
