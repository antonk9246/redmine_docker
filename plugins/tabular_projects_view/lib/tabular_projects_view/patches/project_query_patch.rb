module TabularProjectsView
  module Patches
    module ProjectQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
        base.class_eval do
          self.available_columns += [
            QueryColumn.new(:updated_on, :sortable => "#{Project.table_name}.updated_on"),
            QueryColumn.new(:next_roadmap_due_date),
            QueryColumn.new(:type, :sortable => "#{Project.table_name}.is_private")
          ]
          alias_method :initialize_available_filters_without_custom_filters, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_custom_filters
        end

      end

      module InstanceMethods

        def initialize_available_filters_with_custom_filters
          initialize_available_filters_without_custom_filters
          add_available_filter "updated_on", :type => :date_past
          add_available_filter "member", :type => :list, :values => [[l(:general_text_yes), '1'], [l(:general_text_no), '0']]
          add_available_filter "enum_priority_id", :type => :list, :values => ProjectPriority.sorted.map { |pr| [pr.name, pr.id.to_s] }
          add_available_filter 'enum_status_id', :type => :list, :values => ProjectStatus.sorted.map { |pr| [pr.name, pr.id.to_s] }
          add_available_filter 'roadmap_due_at', :type => :date
          add_available_filter "tracker_id", :type => :list, :label => :label_issue_type, :values => Tracker.sorted.map { |pr| [pr.name, pr.id.to_s] }
          add_available_filter "module", :type => :list, :label => :label_having_module, :values => Redmine::AccessControl.available_project_modules.map { |m| [l_or_humanize(m, :prefix => "project_module_"), m.to_s] }
          add_available_filter "tags", { :type => :list_optional, :values => lambda { tags_values }} if Project.reflect_on_association(:tags)
        end

        def sql_for_module_field(field, operator, value)
          db_table = EnabledModule.table_name
          "#{Project.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.project_id FROM #{db_table} where #{db_table}.name IN (" + value.collect{|val| "'#{ProjectQuery.connection.quote_string(val)}'"}.join(",") + "))"
        end

        def sql_for_tags_field(field, operator, value, db_table=Project.table_name, db_field="")
          case operator
          when "="
            sql = "#{db_table}.id IN (SELECT taggable_id FROM taggings WHERE taggable_type='#{self.queried_class.to_s}' AND taggable_id=#{db_table}.id AND taggings.tag_id IN (" + value.join(",") + "))"
          when "!"
            sql = "#{db_table}.id NOT IN (SELECT taggable_id FROM taggings WHERE taggable_type='#{self.queried_class.to_s}' AND taggable_id=#{db_table}.id AND taggings.tag_id IN (" + value.join(",") + "))"
          when "!*"
            sql = "#{db_table}.id NOT IN (SELECT DISTINCT taggable_id FROM taggings WHERE taggable_type='#{self.queried_class.to_s}')"
          when "*"
            sql = "#{db_table}.id IN (SELECT DISTINCT taggable_id FROM taggings WHERE taggable_type='#{self.queried_class.to_s}')"
          end
          return sql
        end

        def sql_for_member_field(field, operator, value)
          projects = []
          case operator
          when "="
            projects << User.current.projects.uniq if value.include?('1')
            projects << (Project.visible - User.current.projects.uniq) if value.include?('0')
          when "!"
            unless value.include?('1') && value.include?('0')
              if value.include?('1')
                projects << (Project.visible - User.current.projects.uniq)
              elsif value.include?('0')
                projects << User.current.projects.uniq
              end
            end
          end
          projects.flatten!
          projects.any? ? "#{Project.table_name}.id in (#{projects.collect(&:id).join(', ')})" : "1=0"
        end

        def sql_for_tracker_id_field(field, operator, value)
          projects = []
          case operator
          when "="
            projects = Project.visible.has_module('issue_tracking').where("#{Project.table_name}.id IN (SELECT pt.project_id FROM projects_trackers pt WHERE pt.tracker_id IN (#{value.join(',')}))")
          when "!"
            projects = Project.visible.has_module('issue_tracking').where("#{Project.table_name}.id IN (SELECT pt.project_id FROM projects_trackers pt WHERE pt.tracker_id NOT IN (#{value.join(',')}))")
          end
          projects.any? ? "#{Project.table_name}.id in (#{projects.collect(&:id).join(', ')})" : "1=0"

        end

        def sql_for_roadmap_due_at_field(field, operator, value, db_table = Version.table_name, db_field = :effective_date, is_custom_filter = false)
          versions_sql = sql_for_field(field, operator, value, db_table, db_field)
          "#{queried_class.table_name}.id IN (SELECT project_id FROM versions WHERE #{versions_sql})"
        end

        def project_count
          base_scope.count
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end

        def project_count_by_group
          grouped_query do |scope|
            scope.count
          end
        end

        def projects(options={})
          order_option = [group_by_sort_order, options[:order]].reject {|s| s.blank?}.join(',')
          order_option = nil if order_option.blank?
          projects =
            Project.visible
                   .where(statement)
                   .order(order_option)
                   .where(options[:conditions])
                   .includes((options[:include] || []).uniq)
                   .joins(joins_for_order_statement(order_option))
                   .limit(options[:limit])
                   .offset(options[:offset])
          projects
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end

        # Returns the issues ids
        def project_ids(options={})
          order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

          Project.visible.
            where(statement).
            order(order_option).
            where(options[:conditions])
          joins(joins_for_order_statement(order_option.join(','))).
            limit(options[:limit]).
            offset(options[:offset]).
            pluck(:id)
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end

      end

      module ClassMethods;end
    end
  end
end

unless ProjectQuery.included_modules.include?(TabularProjectsView::Patches::ProjectQueryPatch)
  ProjectQuery.send(:include, TabularProjectsView::Patches::ProjectQueryPatch)
end