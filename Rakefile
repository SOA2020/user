# frozen_string_literal: true

namespace :run do
  task :server do
    sh 'rackup -p 9000 --host 0.0.0.0'
  end
end

namespace :db do
  require 'bundler'
  Bundler.require
  Sequel.extension :migration
  require './app/initializers/sequel'

  task :version do
    version = (DB[:schema_info].first[:version] if DB.tables.include?(:schema_info)) || 0

    puts "Schema Version: #{version}"
  end

  task :migrate do
    Sequel::Migrator.run(DB, './app/migrations')
    Rake::Task['db:version'].execute
  end

  task :rollback do |_t, args|
    args.with_defaults(target: 0)

    Sequel::Migrator.run(DB, './app/migrations', target: args[:target].to_i)
    Rake::Task['db:version'].execute
  end

  task :reset do
    Sequel::Migrator.run(DB, './app/migrations', target: 0)
    Sequel::Migrator.run(DB, './app/migrations')
    Rake::Task['db:version'].execute
  end
end
