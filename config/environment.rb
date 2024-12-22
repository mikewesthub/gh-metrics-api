# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

# Require all application files
Dir["#{__dir__}/../models/*.rb"].each { |file| require file }
