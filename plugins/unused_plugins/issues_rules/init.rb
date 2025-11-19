require 'issues_rules'

Redmine::Plugin.register :issues_rules do
  name 'Issues Rules plugin'
  author 'Twinslash'
  description 'Плагин для дополнительной настройки трекеров в проекте'
  version '0.0.1'
  # url 'http://example.com/path/to/plugin'
  # author_url 'http://example.com/about'
  settings :default => {'empty' => true}, :partial => 'settings/issues_rules'
end
