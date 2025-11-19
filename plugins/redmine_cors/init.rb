require 'redmine'
require 'redmine_cors/patches/application_controller'
ActiveSupport::Reloader.to_prepare do
  ApplicationController.send(:include, RedmineCors::Patches::ApplicationControllerPatch)
end

Redmine::Plugin.register :redmine_cors do
  name 'Redmine CORS'
  author 'Marco Vito Moscaritolo, Ramiz Raja'
  description 'This is a plugin for Redmine that make possible CORS request.'
  url 'http://github.com/mavimo/redmine_cors'
  author_url 'http://mavimo.org/'

  version '1.0.0'
  requires_redmine :version_or_higher => '2.0.0'

  settings :partial => 'settings/cors_settings',
    :default => {
      "cors_domain" => "*",
    }
end
