module RbTuning
  module Hooks
    class ControllerTimelogHook < Redmine::Hook::ViewListener

      def controller_time_entries_bulk_edit_before_save(context={})
        time_entry = context[:time_entry]
        time_entry.approve =  context[:params][:time_entry][:approve]
      end
    end
  end
end
