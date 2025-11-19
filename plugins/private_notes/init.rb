require 'redmine'
require 'private_notes/hooks'

Redmine::Plugin.register :private_notes do
  name 'Private Notes plugin'
  author 'Maksim Shylau'
  description 'This is a plugin that allows to set notes as private by default'
  version '0.0.1'
  author_url 'mailto:maksim.shylau@twinslash.com'
  requires_redmine version_or_higher: '2.2.0'
  settings default: {},
           partial: 'settings/private_notes_settings'
end
