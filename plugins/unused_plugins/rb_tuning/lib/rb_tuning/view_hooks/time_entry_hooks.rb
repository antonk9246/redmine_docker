module RbTuning
  module ViewHooks
    class TimeEntryHooks  < Redmine::Hook::ViewListener
      render_on( :view_timelog_edit_form_bottom, :partial => 'timelog/approved_field')
      #render_on( :view_time_entries_bulk_edit_details_bottom, :partial => 'timelog/bulk_edit_approved_field')
      render_on( :view_time_entries_context_menu_start, :partial => 'context_menus/approved_field')
    end
  end
end
