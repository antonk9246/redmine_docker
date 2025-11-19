module RbTuning
  module Patches
    module TimeEntryQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          self.available_columns << QueryColumn.new(:approve, :sortable => "#{TimeEntry.table_name}.approve")

          alias_method :initialize_available_filters_without_add_col, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_add_col
        end
      end

      module InstanceMethods
        def initialize_available_filters_with_add_col
          add_available_filter "approve", :type => :list, :values => lambda { [l(:filter_approve_false), l(:filter_approve_true)].each_with_index.map { |t,i| [t.to_s, i.to_s] } }
          initialize_available_filters_without_add_col
        end
      end
    end
  end
end

TimeEntryQuery.send(:include, RbTuning::Patches::TimeEntryQueryPatch)
