module TabularProjectsView
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.class_eval do

          def project_column_content(column, project)
            value = column.value_object(project)
            if value.is_a?(Array)
              value.collect {|v| project_column_value(column, project, v)}.compact.join(', ').html_safe
            else
              project_column_value(column, project, value)
            end
          end

          def project_column_value(column, project, value)
            case value.class.name
              when 'String'
                if column.name.in?([:name, :identifier])
                  link_to(h(value), {:controller => 'projects', :action => 'show', :id => project}, :title => strip_tags(textilizable(project, :description)), :class => column.name.eql?(:name) && User.current.respond_to?(:all_favourite_marked_projects) && User.current.all_favourite_marked_projects.include?(project) ? 'my-project' : nil)
                else
                  h(value)
                end
              when 'Time'
                format_time(value)
              when 'Date'
                format_date(value)
              when 'Fixnum', 'Float', 'BigDecimal', 'Integer'
                if column.name == :done_ratio
                  progress_bar(value, :width => '80px')
                elsif  column.name == :spent_hours
                  sprintf "%.2f", value
                elsif  column.name == :expected_profit
                  content_tag :span, '', :class => "profit-strip #{project.profit_class}" , :title => humanize_currency(value)
                elsif  column.name.in?([:budget, :expected_profit, :actual_cost, :earned_value, :schedual_variance, :total_expected_actual_cost, :expected_profit])
                  humanize_currency(value)
                elsif column.name == :average_completed_percent
                  "#{value}%"
                elsif column.name.eql?(:status)
                  project.humanize_status
                else
                  h(value.to_s)
                end
              when 'User'
                link_to_user value
              when 'TrueClass'
                l(:general_text_Yes)
              when 'FalseClass'
                l(:general_text_No)
              when "CustomValue"
                if value.custom_field.field_format == 'user' && !value.value.blank?
                  user = User.find(value.value)
                  s = ''
                  s += avatar(user)
                  s += link_to_user(user)
                  s.html_safe
                else
                  value.value
                end
              else
                h(value)
            end
          end

          def retrieve_project_query
            retrieve_query(ProjectQuery, false, :defaults => @default_columns_names)
          end
        end
      end
    end
  end
end

unless QueriesHelper.included_modules.include?(TabularProjectsView::Patches::QueriesHelperPatch)
  QueriesHelper.send :include, TabularProjectsView::Patches::QueriesHelperPatch
end
