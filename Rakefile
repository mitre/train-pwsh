# frozen_string_literal: true

require "bundler/gem_tasks"
require 'github_changelog_generator/task'

task default: %i[]

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'skandwal'
  config.project = 'train-pwsh'
  config.since_tag = '1.0.7'
  config.future_release = '2.0.0'
end
