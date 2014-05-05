require_relative 'helpers/environment'

namespace :db do
  desc "Run DB migrations on db/migrate directory"
  task :migrate do
    require 'sequel'

    Sequel.extension :migration

    env      ||= ENV['RACK_ENV'] || :development

    FunkyWorldCup::Helpers.init_environment(env)
    DB = FunkyWorldCup::Helpers.database

    puts 'Running migrations...'

    Sequel::Migrator.run(DB, "db/migrate")

    puts 'Done!'
  end

  namespace :schema do
    desc "Dump the DB schema to db/schema.rb"
    task :dump do
      require 'sequel'

      env      ||= ENV['RACK_ENV'] || :development

      FunkyWorldCup::Helpers.init_environment(env)
      db = FunkyWorldCup::Helpers.database

      db.extension :schema_dumper

      puts "Dumping schema to db/schema.rb..."

      File.open("db/schema.rb", "w") do |f|
        f.puts db.dump_schema_migration
      end

      puts "Done!"
    end

    desc "Load the DB schema defined in db/schema.rb"
    task :load do
      require 'sequel'

      Sequel.extension :migration

      puts "Loading schema..."
      env      ||= ENV['RACK_ENV'] || :test

      FunkyWorldCup::Helpers.init_environment(env)
      db = FunkyWorldCup::Helpers.database

      migration = eval(File.read('./db/schema.rb'))

      puts "Dropping old tables..."
      db.drop_table *db.tables, cascade: true

      puts "Applying new schema..."
      migration.apply(db, :up)

      puts "Done!"
    end
  end

  namespace :test do
    desc "Prepares test DB by copying current dev schema"
    task :prepare do
      require 'sequel'

      env_val = ENV['RACK_ENV']

      ENV['RACK_ENV'] = 'development'
      Rake::Task["db:schema:dump"].invoke

      ENV['RACK_ENV'] = 'test'
      Rake::Task["db:schema:load"].invoke
    end
  end
end

namespace :test do
  @env = 'test'
  desc "Test all"
  task :all do
    load_files "test/helpers/*.rb"
    load_files "test/routes/*.rb"
    load_files "test/lib/*.rb"
    load_files "test/unit/*.rb"
  end
end

def load_files(dir)
  Dir[dir].each { |file| load file }
end
