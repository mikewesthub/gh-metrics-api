# frozen_string_literal: true

require 'octokit'
require 'dotenv/load'

# Module to instantiate an Octokit client
module OctoKitClient
  PERSONAL_ACCESS_TOKEN = ENV.fetch('PERSONAL_ACCESS_TOKEN')

  def octokit
    @octokit ||= Octokit::Client.new(access_token: PERSONAL_ACCESS_TOKEN)
  end
end
