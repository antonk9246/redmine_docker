# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2010-2022 RedmineUP
# http://www.redmineup.com/
#
# redmine_deals is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_deals is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_deals.  If not, see <http://www.gnu.org/licenses/>.

class DealsIssuesController < ApplicationController
  unloadable

  before_action :find_deal, only: %i[create_issue delete_relation]
  before_action :find_project_by_project_id, only: [:create_issue]
  before_action :find_issue, except: [:create_issue]
  before_action :authorize_global, only: [:close]
  before_action :authorize

  include DealsHelper
  helper :deals

  def create_issue
    deny_access unless User.current.allowed_to?(:manage_contact_issue_relations,
                                                @project) || User.current.allowed_to?(:add_issues, @project)
    issue = Issue.new
    issue.project = @project
    issue.author = User.current
    issue.status = IssueStatus.default if ActiveRecord::VERSION::MAJOR < 4
    issue.start_date ||= Date.today
    issue.safe_attributes = params[:issue] if params[:issue]

    if issue.save
      add_deal_issue issue.id, @deal.id
      flash[:notice] = l(:notice_successful_add)
    else
      flash[:error] = issue.errors.full_messages.join('<br>').html_safe
    end
    redirect_to :back
  end

  def delete_relation
    deny_access unless User.current.allowed_to?(:manage_contact_issue_relations,
                                                @project) || User.current.allowed_to?(:add_issues, @project)

    if remove_deal_issue params[:issue_id], @deal.id
      flash[:notice] = l(:notice_successful_add)
    else
      flash[:error] = l(:error)
    end
    respond_to do |format|
      format.js { render inline: 'location.reload();' }
    end
  end

  def close
    @issue.init_journal(User.current)
    @issue.status = IssueStatus.where(is_closed: true).first
    @issue.save
    respond_to do |format|
      format.js
      format.html { redirect_to :back }
    end
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def find_deal
    @deal = Deal.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
