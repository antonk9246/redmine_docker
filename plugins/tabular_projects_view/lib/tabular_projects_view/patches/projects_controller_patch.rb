#!/bin/env ruby
# encoding: utf-8
module TabularProjectsView
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          include QueriesHelper
          include ProjectsHelper
          helper :queries
          helper :projects
          helper :sort
          include SortHelper

          alias_method :index_without_tabular_view, :index
          alias_method :index, :index_with_tabular_view

          alias_method :settings_without_nonconformities, :settings
          alias_method :settings, :settings_with_nonconformities

          alias_method :update_without_attachments, :update
          alias_method :update, :update_with_attachments
          
          alias_method :create_without_attachments, :create
          alias_method :create, :create_with_attachments

        end
      end

      module InstanceMethods

        def index_with_tabular_view
          retrieve_query(ProjectQuery, true)
          sort_init(@query.sort_criteria.empty? ? [['name', 'asc']] : @query.sort_criteria)
          sort_update(@query.sortable_columns)
          if @query.valid?
            case params[:format]
              when 'csv', 'pdf'
                @limit = Setting.issues_export_limit.to_i
              when 'atom'
                @limit = Setting.feeds_limit.to_i
              when 'xml', 'json'
                @offset, @limit = api_offset_and_limit
              else
                @limit = per_page_option
            end

            @project_count = @query.project_count
            #Showing all projects by default.
            @limit = 50 if !(session[:per_page] || params[:per_page]) && !api_request?
            @project_pages = Redmine::Pagination::Paginator.new @project_count, @limit, params['page']
            @offset ||= @project_pages.offset
            @projects = @query.projects(:order => sort_clause,
                                        :offset => @offset,
                                        :limit => @limit,
                                        :include => [:enabled_modules, :custom_values, :parent, :attachments]
                                        )
            @project_count_by_group = @query.project_count_by_group

            if params[:projects_view_type].present?
              session[:projects_view_type] = params[:projects_view_type]
            end
            respond_to do |format|
              format.html { render :template => 'projects/index', :layout => !request.xhr? }
              format.api {
              }
              format.atom { render_feed(@projects, :title => "#{Setting.app_title}: #{l(:label_project_plural)}") }
              format.csv {
                send_data(projects_to_csv(@projects, @query, params), :type => 'text/csv; header=present', :filename => 'export.csv')
              }
            end
          else
            respond_to do |format|
              format.html { render(:template => 'projects/index', :layout => !request.xhr?) }
              format.any(:atom, :csv, :pdf) { render(:nothing => true) }
              format.api { render_validation_errors(@query) }
            end
          end
          
        end
        rescue ActiveRecord::RecordNotFound
          render_404
        end


        def update_with_attachments
          @project.safe_attributes = params[:project]
          if @project.save
            if params[:attachments]
              params[:attachments].each do |file|
                @project.attachments.create(
                  file: file,
                  author_id: User.current.id
                )
              end
            end
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_update)
                redirect_to settings_project_path(@project, params[:tab])
              }
              format.api  { render_api_ok }
            end
          else
            respond_to do |format|
              format.html {
                settings
                render :action => 'settings'
              }
              format.api  { render_validation_errors(@project) }
            end
          end
        end

        def create_with_attachments
          @issue_custom_fields = IssueCustomField.sorted.to_a
          @trackers = Tracker.sorted.to_a
          @project = Project.new
          @project.safe_attributes = params[:project]

          if @project.save
            if params[:attachments]
              params[:attachments].each do |file|
                @project.attachments.create(
                  file: file,
                  author_id: User.current.id
                )
              end
            end
            unless User.current.admin?
              @project.add_default_member(User.current)
            end
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_create)
                if params[:continue]
                  attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
                  redirect_to new_project_path(attrs)
                else
                  redirect_to settings_project_path(@project)
                end
              }
              format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
            end
          else
            respond_to do |format|
              format.html { render :action => 'new' }
              format.api  { render_validation_errors(@project) }
            end
          end
        end

        def settings_with_nonconformities
          settings_without_nonconformities
          @nonconformities = @project.nonconformities
        end
    end
  end
end

unless ProjectsController.included_modules.include?(TabularProjectsView::Patches::ProjectsControllerPatch)
  ProjectsController.send :include, TabularProjectsView::Patches::ProjectsControllerPatch
end

