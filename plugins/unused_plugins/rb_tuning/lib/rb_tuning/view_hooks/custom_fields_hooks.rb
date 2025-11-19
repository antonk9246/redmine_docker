module RbTuning
  module ViewHooks
    class CustomFieldHooks  < Redmine::Hook::ViewListener
      render_on( :view_custom_fields_form_upper_box, :partial => 'custom_fields/edit_additional_fields')
    end
  end
end