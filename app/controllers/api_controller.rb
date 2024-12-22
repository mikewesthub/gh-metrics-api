# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../models/copilot'
require 'sinatra'

class ApiController < ApplicationController
  get '/' do
    puts 'This should lead to some sort of configuration'
  end

  get '/copilot/:org/daily_summary' do
    org = params['org']
    copilot = Copilot.new(org: org)
    copilot.daily_org_summary.to_json
  end

  get '/copilot/:org/team/:team_slug/daily_summary' do
    org = params['org']
    team_slug = params['team_slug']
    copilot = Copilot.new(org: org, team_slug: team_slug)
    copilot.daily_team_summary.to_json
  end

  get '/pull_request/:org/:repo/lines_of_code' do
    org = params['org']
    repo = params['repo']
    pr = PullRequest.new(org: org, repo: repo)
    pr.lines_of_code_since(pr.start_date)
  end
end
