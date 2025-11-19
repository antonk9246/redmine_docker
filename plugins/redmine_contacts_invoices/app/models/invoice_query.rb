class TechnicalReportQuery < Query
  self.queried_class = TechnicalReport
  self.view_permission = :view_technical_reports

  self.available_columns = [
    QueryColumn.new(:id, :sortable => "#{TechnicalReport.table_name}.id", :caption => :field_technical_report_id),
    QueryColumn.new(:issue, :sortable => "#{Issue.table_name}.subject", :caption => :field_issue),
    QueryColumn.new(:start_date, :sortable => "#{TechnicalReport.table_name}.start_date", :caption => :field_start_date),
    QueryColumn.new(:we, :sortable => "#{TechnicalReport.table_name}.we", :caption => :field_we),
    QueryColumn.new(:floors_worked, :sortable => "#{TechnicalReport.table_name}.floors_worked", :caption => :field_floors_worked),
    QueryColumn.new(:udo_status, :sortable => "#{TechnicalReport.table_name}.udo_status", :caption => :field_udo_status),
    QueryColumn.new(:test_status, :sortable => "#{TechnicalReport.table_name}.test_status", :caption => :field_test_status),
    QueryColumn.new(:approved, :sortable => "#{TechnicalReport.table_name}.approved", :caption => :field_approved),
    QueryColumn.new(:group, :sortable => "#{Group.table_name}.lastname", :caption => :field_group),
    QueryColumn.new(:driver, :sortable => lambda { User.fields_for_order_statement }, :caption => :field_driver),
    QueryColumn.new(:documenter, :sortable => lambda { User.fields_for_order_statement }, :caption => :field_documenter),
    QueryColumn.new(:created_at, :sortable => "#{TechnicalReport.table_name}.created_at", :caption => :field_created_on),
    QueryColumn.new(:updated_at, :sortable => "#{TechnicalReport.table_name}.updated_at", :caption => :field_updated_on),
    QueryColumn.new(:comment, :caption => :field_comment)
  ]

  def initialize(attributes = nil, *args)
    super attributes
    self.filters ||= { 'status' => { :operator => 'o', :values => [''] } }
  end

  def initialize_available_filters
    add_available_filter 'id', :type => :integer, :label => :field_technical_report_id
    add_available_filter 'issue_id', :type => :integer, :label => :field_issue
    add_available_filter 'start_date', :type => :date, :label => :field_start_date
    add_available_filter 'we', :type => :string, :label => :field_we
    add_available_filter 'floors_worked', :type => :integer, :label => :field_floors_worked
    
    add_available_filter 'udo_status', 
      :type => :list, 
      :values => TechnicalReport.udo_statuses.map { |k,v| [v, k] },
      :label => :field_udo_status
    
    add_available_filter 'test_status', 
      :type => :list, 
      :values => TechnicalReport.test_statuses.map { |k,v| [v, k] },
      :label => :field_test_status
    
    add_available_filter 'approved', 
      :type => :list, 
      :values => [[l(:general_text_yes), '1'], [l(:general_text_no), '0']],
      :label => :field_approved
    
    add_available_filter 'group_id', 
      :type => :list, 
      :values => Group.all.map { |g| [g.name, g.id.to_s] },
      :label => :field_group
    
    add_available_filter 'driver_id', 
      :type => :list, 
      :values => User.active.map { |u| [u.name, u.id.to_s] },
      :label => :field_driver
    
    add_available_filter 'documenter_id', 
      :type => :list, 
      :values => User.active.map { |u| [u.name, u.id.to_s] },
      :label => :field_documenter
    
    add_available_filter 'created_at', :type => :date, :label => :field_created_on
    add_available_filter 'updated_at', :type => :date, :label => :field_updated_on
    add_available_filter 'comment', :type => :text, :label => :field_comment

    initialize_project_filter
    initialize_author_filter
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns += CustomField.where(:type => 'TechnicalReportCustomField').all.map { |cf| QueryCustomFieldColumn.new(cf) }
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||= [:id, :issue, :start_date, :we, :floors_worked, :udo_status, :approved]
  end

  def sql_for_udo_status_field(field, operator, value)
    sql_for_field(field, operator, value, TechnicalReport.table_name, field)
  end

  def sql_for_test_status_field(field, operator, value)
    sql_for_field(field, operator, value, TechnicalReport.table_name, field)
  end

  def sql_for_approved_field(field, operator, value)
    op = (operator == '=' ? 'IN' : 'NOT IN')
    va = value.map { |v| v == '0' ? self.class.connection.quoted_false : self.class.connection.quoted_true }.uniq.join(',')
    "#{TechnicalReport.table_name}.approved #{op} (#{va})"
  end

  def sql_for_group_id_field(field, operator, value)
    sql_for_field(field, operator, value, TechnicalReport.table_name, field)
  end

  def sql_for_driver_id_field(field, operator, value)
    sql_for_field(field, operator, value, TechnicalReport.table_name, field)
  end

  def sql_for_documenter_id_field(field, operator, value)
    sql_for_field(field, operator, value, TechnicalReport.table_name, field)
  end

  def objects_scope(options={})
    scope = TechnicalReport.visible
    options[:search].split(' ').collect{ |search_string| scope = scope.live_search(search_string) } unless options[:search].blank?
    scope = scope.includes((query_includes + (options[:include] || [])).uniq).
      where(statement).
      where(options[:conditions])
    scope
  end

  def query_includes
    includes = [:issue, :group, :driver, :documenter]
    includes << :project if self.filters["project_id"] || (group_by_column && [:project].include?(group_by_column.name))
    includes
  end
end