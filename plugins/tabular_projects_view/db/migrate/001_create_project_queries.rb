class CreateProjectQueries < Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :project_queries do |t|
      t.string :name
      t.text :filters
      t.integer :user_id
      t.boolean :is_public
      t.text :column_names
      t.text :sort_criteria
      t.string :group_by
    end
  end
end
