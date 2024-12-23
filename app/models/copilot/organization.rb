# frozen_string_literal: true

require_relative '../../services/octokit_client'
require_relative 'metric_calculations'
require 'pry'

module Copilot
  # Access Copilot metrics from the GitHub API
  class Organization
    include OctoKitClient
    include MetricCalculations

    attr_reader :org, :team

    # defaults for testing only. org will be required and team will be optional
    def initialize(org: 'octodemo', team: 'solution-engineers')
      @org = org
      @team = team
    end

    # Organization level presenters for metrics

    def daily_summary
      daily_summary_for(metrics)
    end

    def daily_team_summary
      daily_summary_for(team_metrics)
    end

    def license_breakdown
      summary = license_summary.to_h
      summary.merge(license_usage: license_utilization)
    end

    def team_acceptance_percentage
      calculate_percentage_for(
        total_lines_accepted_for(team_usage).to_f / total_lines_suggested_for(team_usage)
      )
    end

    def acceptance_percentage
      calculate_percentage_for(
        total_lines_accepted_for(usage).to_f / total_lines_suggested_for(usage)
      )
    end

    def license_utilization
      breakdown = license_summary.seat_breakdown

      calculate_percentage_for(
        breakdown.active_this_cycle.to_f / breakdown.total
      )
    end

    # Organization API

    def usage
      @usage ||= octokit.get("/orgs/#{org}/copilot/usage", per_page: 100)
    end

    def metrics
      @metrics ||= octokit.get("/orgs/#{org}/copilot/metrics", per_page: 100)
    end

    def team_usage
      @team_usage ||= octokit.get("/orgs/#{org}/teams/#{team}/copilot/usage", per_page: 100)
    end

    def team_metrics
      @team_metrics ||= octokit.get("/orgs/#{org}/teams/#{team}/copilot/metrics", per_page: 100)
    end

    def licenses_assigned
      @licenses_assigned ||= octokit.get("/orgs/#{org}/copilot/billing/seats", per_page: 100)
    end

    def license_summary
      @license_summary ||= octokit.get("/orgs/#{org}/copilot/billing", per_page: 100)
    end
  end
end
