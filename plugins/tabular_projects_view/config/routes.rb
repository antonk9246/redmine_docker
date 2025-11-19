# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match '/project/context_menu', :to => 'context_menus#projects', :as => 'projects_context_menu', :via => [:get, :post]

resources :projects_queries, :except => :index