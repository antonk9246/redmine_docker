class AddAllowAllTrackersPermissionToRole < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :allow_all_trackers_permission, :boolean, default: true
  end
end
