# migration related to PM Dashboard plugin
class AddOptionsToProjectQueries < Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    if Redmine::Plugin.installed?(:redmine_pm_dashboard) && !column_exists?(:project_queries, :options)
      add_column :project_queries, :options, :text
    end
  end

  def down
    remove_column :project_queries, :options if Redmine::Plugin.installed?(:redmine_pm_dashboard)
  end
end
