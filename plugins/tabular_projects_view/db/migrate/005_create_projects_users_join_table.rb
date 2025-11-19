class CreateProjectsUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_join_table :projects, :users do |t|
      t.index [:project_id, :user_id], unique: true
      t.timestamps
    end
  end
end