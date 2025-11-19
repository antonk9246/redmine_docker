class AddRbTagColumnToTheTables < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :custom_fields, :rb_tag, :string , :limit => 30
    add_index :custom_fields, :rb_tag
    
    add_column :custom_field_enumerations, :rb_tag, :string , :limit => 30
    add_index :custom_field_enumerations,:rb_tag
    
    add_column :issue_statuses, :rb_tag, :string , :limit => 30
    add_index :issue_statuses,:rb_tag
    
    add_column :trackers, :rb_tag, :string , :limit => 30
    add_index :trackers, :rb_tag
  end
end
