module PrivateNotes
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_edit_notes_bottom(context)
      project = context[:project]
      roles_with_users = project.users_by_role.select do |_role, users|
        users.select { |user| user.name == User.current.name }.count > 0
      end
      roles = roles_with_users.map { |array| array.first.name }
      roles_should_have_private_notes = Setting.plugin_private_notes.keys
      return if (roles - roles_should_have_private_notes).count == roles.count

      javascript_include_tag 'private_notes.js', plugin: 'private_notes'
    end
  end
end
