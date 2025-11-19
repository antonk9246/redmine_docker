module TabularProjectsView
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

      end

      module InstanceMethods

        def projects_to_csv(projects, query, options={})
          decimal_separator = l(:general_csv_decimal_separator)
          encoding = l(:general_csv_encoding)
          columns = (options[:columns] == 'all' ? query.available_columns : query.columns)

          export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
            # csv header fields
            csv << [ "#" ] + columns.collect {|c| Redmine::CodesetUtil.from_utf8(c.caption.to_s, encoding) } +
                (options[:description] ? [Redmine::CodesetUtil.from_utf8(l(:field_description), encoding)] : [])

            # csv lines
            Project.project_tree(projects) do |project, level|
              col_values = columns.collect do |column|
                s = if column.is_a?(QueryCustomFieldColumn)
                      cv = project.custom_field_values.detect {|v| v.custom_field_id == column.custom_field.id}
                      show_value(cv)
                    else
                      value = column.value(project)
                      if value.is_a?(Date)
                        format_date(value)
                      elsif value.is_a?(Time)
                        format_time(value)
                      elsif value.is_a?(Float)
                        ("%.2f" % value).gsub('.', decimal_separator)
                      else
                        value
                      end
                    end
                s.to_s
              end
              csv << [ project.identifier.to_s ] + col_values.collect {|c| Redmine::CodesetUtil.from_utf8(c.to_s, encoding) } +
                  (options[:description] ? [Redmine::CodesetUtil.from_utf8(project.description, encoding)] : [])
            end
          end
          export
        end

        def toggle_project_arrows(project_id)
          content_tag(:span, '', :class => "collapse-row", id: "parent-project-#{project_id}")
        end

        def child_row_classes(project,all_projects)
          classes = project.ancestors.collect{|p| "child-project-#{p.id}"}.join(' ')
          classes << " hidden" if project.parent.in?(all_projects)
          classes
        end

        def sidebar_project_queries
          unless @sidebar_queries
            @sidebar_queries = ProjectQuery.visible.order(Arel.sql("#{ProjectQuery.table_name}.name ASC"))
          end
          @sidebar_queries
        end

        def render_sidebar_project_queries
          out = ''.html_safe
          out << query_links(l(:label_query_plural), sidebar_project_queries)
          out
        end

        def render_project_hierarchy_without_description(projects)
          render_project_nested_lists(projects) do |project|
            s = link_to_project(project, {}, :class => "#{project.css_classes} #{User.current.member_of?(project) ? "icon icon-user my-project" : nil }")
            s += textilizable(project.description)
            s.html_safe
          end
        end
      end
    end

  end
end

unless ProjectsHelper.included_modules.include?(TabularProjectsView::Patches::ProjectsHelperPatch)
  ProjectsHelper.send :include, TabularProjectsView::Patches::ProjectsHelperPatch
end
