# frozen_string_literal: true

require_relative '../services/octokit_client'
require 'parallel'

module GhMetricCollector
  # Access Pull Requests from the GitHub API
  class PullRequest
    include OctoKitClient

    attr_reader :org, :repo

    def initialize(org: 'octodemo', repo: 'demo-vulnerabilities-ghas')
      @org = org
      @repo = repo
    end

    def list
      @list_prs = octokit.get("/repos/#{org}/#{repo}/pulls", per_page: 100)
    end

    def get_pr(number)
      @get_pr = octokit.get("/repos/#{org}/#{repo}/pulls/#{number}")
    end

    def prs_since(date)
      list.select { |pr| pr.created_at > date }
    end

    def lines_of_code_since(date)
      prs = prs_since(date)

      lines_per_pr = Parallel.map(prs, in_threads: 4) do |pr|
        get_pr(pr.number).additions
      rescue Octokit::Error => e
        puts "Error fetching PR #{pr.number}: #{e.message}"
      end

      lines_per_pr.sum
    end

    def start_date
      time = Time.now.utc

      # weekly snapshot? monthly?
      Time.utc(time.year, time.month, time.day - 7)
    end
  end
end
