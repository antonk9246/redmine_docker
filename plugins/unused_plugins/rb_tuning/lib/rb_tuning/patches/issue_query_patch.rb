module RbTuning
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          new_columns = [QueryColumn.new(:deadline_changed, :sortable => "#{Issue.table_name}.deadline_changed"),
                        QueryColumn.new(:planned_date, :sortable => "#{Issue.table_name}.planned_date"),
                        QueryColumn.new(:additional_time, :sortable => "#{Issue.table_name}.additional_time")]

          self.available_columns += new_columns

          alias_method :initialize_available_filters_without_add_col, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_add_col
        end
      end

      module InstanceMethods
        def initialize_available_filters_with_add_col
          add_available_filter "planned_date", :type => :date
          add_available_filter "deadline_changed", :type => :date
          add_available_filter "additional_time", :type => :integer
          initialize_available_filters_without_add_col
        end
      end
    end
  end
end

IssueQuery.send(:include, RbTuning::Patches::IssueQueryPatch)
