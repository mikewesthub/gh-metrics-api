# frozen_string_literal: true

require_relative '../services/octokit_client'
require 'parallel'

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
end
