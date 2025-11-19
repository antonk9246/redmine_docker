class ProjectStatus < Enumeration

  after_destroy { |status| status.class.compute_position_names }
  after_save { |status| status.class.compute_position_names if status.position_changed? && status.position }

  OptionName = :enumeration_project_statuses

  def option_name
    OptionName
  end

  def css_classes
    "status-#{id} status-#{position_name}"
  end

  # Clears position_name for all statuses
  # Called from migration 20121026003537_populate_enumerations_position_name
  def self.clear_position_names
    update_all :position_name => nil
  end

  # Updates position_name for active statuses
  # Called from migration 20121026003537_populate_enumerations_position_name
  def self.compute_position_names
    statuses = where(:active => true).sort_by(&:position)
    if statuses.any?
      default = statuses.detect(&:is_default?) || statuses[(statuses.size - 1) / 2]
      statuses.each_with_index do |status, index|
        name = case
                 when status.position == default.position
                   "default"
                 when status.position < default.position
                   index == 0 ? "lowest" : "low#{index+1}"
                 else
                   index == (statuses.size - 1) ? "highest" : "high#{statuses.size - index}"
               end

        where(:id => status.id).update_all({:position_name => name})
      end
    end
  end
end
