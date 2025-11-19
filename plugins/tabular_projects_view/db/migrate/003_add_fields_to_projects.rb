class AddFieldsToProjects < Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    add_column :projects, :enum_status_id, :integer, default: 0, null: false
    add_column :projects, :enum_priority_id, :integer, default: 0, null: false

    %w(Low High Urgent).each do |priority_name|
      ProjectPriority.where(name: priority_name).first_or_create
    end
    normal_priority = ProjectPriority.where(name: 'Normal',
                                            is_default: true).first_or_create

    ProjectStatus.where(name: 'New',
                        is_default: true).first_or_create
    ProjectStatus.where(name: 'On hold').first_or_create
    in_progress_status = ProjectStatus.where(name: 'In progress').first_or_create
    closed_status = ProjectStatus.where(name: 'Closed').first_or_create

    Project.active.update_all(enum_status_id: in_progress_status.id,
                              enum_priority_id: normal_priority.id)
    Project.where(status: [Project::STATUS_CLOSED, Project::STATUS_ARCHIVED])
           .update_all(enum_status_id: closed_status.id,
                       enum_priority_id: normal_priority.id)
  end

  def self.down
    remove_column :projects, :enum_status_id
    remove_column :projects, :enum_priority_id
  end
end
