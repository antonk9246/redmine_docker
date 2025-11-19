class AddGitToProjects < Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :git, :boolean, :default => false
  end
end
