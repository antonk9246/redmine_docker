class ProjectsQueriesController < ApplicationController

  before_action :find_query, :except => [:new, :create, :index]

  include QueriesHelper
  include ProjectsHelper
  helper :queries
  helper :projects

  def new
    @query = ProjectQuery.new
    @query.user = User.current
    @query.build_from_params(params)
  end

  def create
    @query = ProjectQuery.new
    @query.user = User.current
    update_query_from_params

    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_projects(:query_id => @query)
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    update_query_from_params

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_projects(:query_id => @query)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to_projects(:set_filter => 1)
  end

  private

    def find_query
      @query = ProjectQuery.find(params[:id])
      render_403 unless @query.editable_by?(User.current)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def update_query_from_params
      @query.build_from_params(params)
      @query.column_names = nil if params[:default_columns]
      @query.name = params[:query] && params[:query][:name]
      if User.current.allowed_to?(:manage_public_queries, @query.project) || User.current.admin?
        @query.visibility = (params[:query] && params[:query][:visibility]) || IssueQuery::VISIBILITY_PRIVATE
        @query.role_ids = params[:query] && params[:query][:role_ids]
      else
        @query.visibility = IssueQuery::VISIBILITY_PRIVATE
      end
      @query
    end

    def redirect_to_projects(options)
      if params[:pm_dashboard]
        redirect_to global_dashboard_path(options)
      else
        redirect_to projects_path(options)
      end
    end

end
