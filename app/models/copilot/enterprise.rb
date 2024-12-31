# frozen_string_literal: true

require_relative '../../services/octokit_client'
require_relative '../../services/graphql_queries'
require_relative 'metric_calculations'
require_relative 'organization'
require 'parallel'

require 'pry'

module Copilot
  # Access Copilot Enterprise metrics from the GitHub API
  class Enterprise
    include OctoKitClient
    include MetricCalculations
    include GraphQLQueries

    attr_reader :ent

    def initialize(ent:)
      @ent = ent
    end

    def daily_summary
      daily_summary_for(metrics)
    end

    def acceptance_percentage
      calculate_percentage_for(
        total_acceptances_for(usage).to_f / total_suggestions_for(usage)
      )
    end

    def acceptance_by_language
      acceptance_by_language_for(usage)
    end

    def license_breakdown
      # Will only return the license breakdown for the first 100 organizations
      license_breakdown_for(organization_summaries)
    end

    def paginated_license_breakdown
      license_breakdown_for(paginated_organization_summaries)
    end

    private

    def license_breakdown_for(organization_summaries)
      license_summaries = successes_for(organization_summaries)
      errors = errors_for(organization_summaries)

      breakdown = {
        total_seats: licenses_assigned.total_seats,
        added_this_cycle: 0,
        active_this_cycle: 0,
        inactive_this_cycle: 0
      }

      license_summaries.each do |summary|
        breakdown[:added_this_cycle] += summary.seat_breakdown.added_this_cycle
        breakdown[:active_this_cycle] += summary.seat_breakdown.active_this_cycle
        breakdown[:inactive_this_cycle] += summary.seat_breakdown.inactive_this_cycle
      end

      breakdown.merge(
        license_usage: calculate_percentage_for(
          breakdown[:active_this_cycle].to_f / (breakdown[:active_this_cycle] + breakdown[:inactive_this_cycle])
        ),
        errors: {
          count: errors.count,
          organizations: errors
        }
      )
    end

    def successes_for(summaries)
      summaries.reject { |summary| summary.key?(:error) }
    end

    def errors_for(summaries)
      summaries.select { |summary| summary.key?(:error) }
    end

    def organization_summaries
      organization_summaries_for(organizations)
    end

    def paginated_organization_summaries
      organization_summaries_for(all_organizations)
    end

    def organization_summaries_for(organizations)
      Parallel.map(organizations, in_threads: Parallel.processor_count) do |org|
        Copilot::Organization.new(org: org['login']).license_summary
      rescue Octokit::NotFound
        # User must be an owner of each organization to access this data
        # TODO: This error handling should be presented to the user 
        # - more descriptive error should be logged
        { error: "#{org['login']} not found" }
      end
    end

    def organizations
      response = GraphQLAPI::Client.query(
        GraphQLQueries::EnterpriseOrganizationsQuery,
        variables: { slug: ent }
      )

      # return Organizations nodes as an array of hashes
      response.data.enterprise.organizations.to_h['nodes']
    end

    def all_organizations
      # Allows to return all organizations when an Enterprise has greater than 100 organizations
      # This is more orgs than most should have, but it's possible
      after_cursor = nil
      organizations = []

      loop do
        response = GraphQLAPI::Client.query(
          GraphQLQueries::EnterpriseAllOrganizationsQuery,
          variables: { slug: ent, after: after_cursor }
        )

        orgs = response.data.enterprise.organizations.to_h
        organizations << orgs['nodes']
        break unless orgs['pageInfo']['hasNextPage']

        after_cursor = orgs['pageInfo']['endCursor']
      end

      organizations.flatten
    end

    # Enterprise API

    def usage
      @usage ||= octokit.get("/enterprises/#{ent}/copilot/usage")
    end

    def metrics
      @metrics ||= octokit.get("/enterprises/#{ent}/copilot/metrics")
    end

    def licenses_assigned
      @licenses_assigned ||= octokit.get("/enterprises/#{ent}/copilot/billing/seats")
    end
  end
end
