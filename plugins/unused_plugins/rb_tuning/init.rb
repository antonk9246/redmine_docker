require 'rb_tuning'

Redmine::Plugin.register :rb_tuning do
  name 'Rb tuning plugin'
  author 'Twinslash'
  description 'Issue add time -Accounting for additional time for the task. Spent time approve.'
  version '0.0.1'
  # url 'http://example.com/path/to/plugin'
  # author_url 'http://example.com/about'
  settings :default => {'empty' => true}, :partial => 'settings/rb_tuning'
end
