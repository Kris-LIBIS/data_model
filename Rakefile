require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'active_record'
require 'active_record/migration'

namespace :db do

  env = ENV['RUBY_ENV'] || "development"
  db_config_file = 'config/database.yml'
  db_config = YAML::load_file(db_config_file)[env]

  # noinspection RubyStringKeysInHashInspection
  db_config_admin = db_config.merge(
      {
          'database' => 'postgres',
          'schema_search_path' => 'public',
          'username' => db_config['dba_name'],
          'password' => db_config['dba_pass'],
      }
  )

  #noinspection RubyStringKeysInHashInspection
  db_config_dba = db_config.merge(
      {
          'schema_search_path' => 'public',
          'username' => db_config['dba_name'],
          'password' => db_config['dba_pass'],
      }
  )

  #noinspection RubyStringKeysInHashInspection
  db_config_public = db_config.merge(
      {
          'schema_search_path' => 'public',
      }
  )

  desc 'Create the database'
  task :create => [:create_db, :create_db_schema] do
  end

  desc 'Create the database itself'
  task :create_db do
    ActiveRecord::Base.establish_connection(db_config_admin)
    conn = ActiveRecord::Base.connection
    conn.create_database(db_config['database'], owner: db_config['username'])
    puts 'Database created.'
  end

  desc 'Create Database schema'
  task :create_db_schema do
    ActiveRecord::Base.establish_connection(db_config_dba)
    conn = ActiveRecord::Base.connection
    conn.execute("CREATE SCHEMA \"#{db_config['username']}\" AUTHORIZATION #{db_config['username']}")
    conn.execute("CREATE SCHEMA \"#{db_config['username']}_password\" AUTHORIZATION #{db_config['username']}_password")
    conn.execute("GRANT USAGE ON SCHEMA \"#{db_config['username']}\" TO \"#{db_config['username']}_password\"")
    conn.execute("GRANT USAGE ON SCHEMA \"#{db_config['username']}_password\" TO \"#{db_config['username']}\"")
    conn.enable_extension 'pgcrypto' unless conn.extension_enabled?('pgcrypto')
    puts 'Database Schema created.'
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.migration_context.migrate
    Rake::Task['db:schema'].invoke
    puts 'Database migrated.'
  end

  desc 'Kill open DB connections'
  task :kill_connections do
    db_name = db_config['database']
    `psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='#{db_name}' AND pid <> pg_backend_pid();" -d '#{db_name}'`
    puts 'Database connections closed.'
  end

  desc 'Drop the database'
  task :drop => [:kill_connections, :drop_db_schema, :drop_db] do
  end

  desc 'Drop the database itself'
  task :drop_db => :kill_connections do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.drop_database(db_config['database'])
    puts 'Database deleted.'
  end

  desc 'Drop Database schema'
  task :drop_db_schema => :kill_connections do
    ActiveRecord::Base.establish_connection(db_config_dba)
    conn = ActiveRecord::Base.connection
    conn.drop_schema(db_config['username'], if_exists: true)
    conn.drop_schema(db_config['username'] + '_password', if_exists: true)
    puts 'Database Schema deleted.'
  end

  desc 'Reset the database'
  task :reset => [:drop, :create, :migrate, :schema]

  desc 'Recreate the database'
  task :recreate => [:drop, :create, :migrate, :schema, :seed]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    ActiveRecord::Base.establish_connection(db_config)
    require 'active_record/schema_dumper'
    filename = 'db/schema.rb'
    File.open(filename, 'w:utf-8') do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  desc 'Load the database seed files'
  task :seed do
    ActiveRecord::Base.establish_connection(db_config)
    # noinspection RubyResolve
    load File.join(__dir__, 'db', 'seeds.rb')
  end

end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration
  def self.up
  end
  def self.down
  end
end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end

