# frozen_string_literal: true

namespace :coverband do
  # handles configuring in require => false and COVERBAND_DISABLE_AUTO_START cases
  Coverband.configure unless Coverband.configured?

  desc "report runtime Coverband code coverage"
  task :coverage do
    Coverband::Reporters::ConsoleReport.report(Coverband.configuration.store)
  end

  if defined?(RubyVM::AbstractSyntaxTree)
    require "coverband/utils/dead_methods"

    desc "Output all dead methods"
    task :dead_methods do
      Coverband::Utils::DeadMethods.output_all
    end
  end

  desc "report runtime Coverband code coverage"
  task :coverage_server do
    if Rake::Task.task_defined?("environment")
      Rake.application["environment"].invoke
    end
    if Coverband.configuration.store.is_a?(Coverband::Adapters::FileStore)
      Coverband.configuration.store.merge_mode = true
    end
    Rack::Server.start app: Coverband::Reporters::Web.new,
                       Port: ENV.fetch("COVERBAND_COVERAGE_PORT", 9022).to_i,
                       Host: ENV.fetch("COVERBAND_COVERAGE_HOST", 0.0.0.0)
  end

  ###
  # clear data helpful for development or after configuration issues
  ###
  desc "reset Coverband coverage data, helpful for development, debugging, etc"
  task :clear do
    Coverband.configuration.store.clear!
  end

  ###
  # Updates the data in the coverband store from one format to another
  ###
  desc "upgrade previous Coverband datastore to latest format"
  task :migrate do
    Coverband.configuration.store.migrate!
  end
end
