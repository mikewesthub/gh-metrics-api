# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../models/copilot/enterprise'
require_relative '../models/copilot/organization'

class ApiController < ApplicationController
  get '/' do
    puts 'This should lead to some sort of configuration'
  end

  # Organization level Copilot metrics

  get '/copilot/organization/:org/daily_summary' do
    org = params['org']
    copilot = Copilot::Organization.new(org: org)
    copilot.daily_org_summary.to_json
  end

  get '/copilot/organization/:org/team/:team_slug/daily_summary' do
    org = params['org']
    team_slug = params['team_slug']
    copilot = Copilot::Organization.new(org: org, team_slug: team_slug)
    copilot.daily_team_summary.to_json
  end

  get '/copilot/organization/:org/license_breakdown' do
    org = params['org']
    copilot = Copilot::Organization.new(org: org)
    copilot.license_breakdown.to_json
  end

  # Enterprise level Copilot metrics

  get '/copilot/enterprise/:ent/daily_summary' do
    ent = params['ent']
    enterprise = Copilot::Enterprise.new(ent: ent)
    enterprise.daily_summary.to_json
  end

  get '/copilot/enterprise/:ent/license_breakdown' do
    ent = params['ent']
    enterprise = Copilot::Enterprise.new(ent: ent)
    enterprise.license_breakdown.to_json
  end

  # Pull Request metrics
  get '/pull_request/organization/:org/repository/:repo/lines_of_code' do
    org = params['org']
    repo = params['repo']
    pr = PullRequest.new(org: org, repo: repo)
    pr.lines_of_code_since(pr.start_date)
  end
end
