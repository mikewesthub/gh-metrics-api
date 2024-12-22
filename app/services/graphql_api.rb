# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'
require 'dotenv/load'
require 'pry'

module GraphQLAPI
  HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(context)
      {
        'Authorization' => "Bearer #{ENV.fetch('PERSONAL_ACCESS_TOKEN')}",
        'Content-Type' => 'application/json'
      }
    end
  end

  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
