require 'i18n'
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

  desc "Seed the database with the teams and matches for FIFA World Cup 2014"
  task :seed, [:year] do |t, args|
    env ||= ENV['RACK_ENV'] || :development
    FunkyWorldCup::Helpers.init_environment(env)

    require './lib/seed_loader'

    puts 'Seeding...'

    if args[:year]
      SeedLoader.new(true, "db/seeds/worldcup_#{args[:year]}.yml").seed true
    else
      SeedLoader.new.seed true
    end

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
    load_files "test/jobs/*.rb"
  end
end

namespace :teams do
  desc "Fixes teams to use FIFA names"
  task :fifa do
    require './app'

    puts "Updating..."
    cote_ivory = Team.find(:iso_code => "CI")
    cote_ivory.update(:name => "Côte d'Ivoire") if cote_ivory
    
    england = Team.find(:iso_code => "GB")
    england.update(:name => "England") if england
    
    bosnia = Team.find(:iso_code => "BA")
    bosnia.update(:name => "Bosnia and Herzegovina") if bosnia
    
    korea = Team.find(:iso_code => "KR")
    korea.update(:name => "Korea Republic") if korea

    usa = Team.find(:iso_code => "US")
    usa.update(:name => "USA") if usa
    puts "Done!"
  end
end

namespace :positions do
  desc "Regenerate first phase positions tables"
  task :regenerate do
    require './app'

    puts "Renerating..."
    FunkyWorldCup::Helpers.database.transaction do
      GroupPosition.dataset.destroy
      CupGroup.groups_phase.all.each do |group|
        puts "Renerating...Group #{group.name}"
        group.teams.each do |team|
          GroupPosition.create(
            group_id: group.id,
            team_id: team.iso_code
          )
        end
        group.matches.each do |match|
          GroupPosition.update_positions(match, match.result) unless match.result.nil?
        end
      end
    end
    puts "Done!"
  end
end

namespace :phase do
  namespace :semifinals do
    desc 'Fix inverted semifinals'
    task :fix do
      require './app'

      puts "Starting..."
      FunkyWorldCup::Helpers.database.transaction do
        CupGroup.where(phase: 'semi_finals').first.matches.each do |match|
          puts "Match: #{match.host_id} vs #{match.rival_id}"
          puts "--> Invert match"
          match.update(
            rival_id: match.host_id,
            rival_code: match.host_code,
            rival_description: match.host_description,
            host_id: match.rival_id,
            host_code: match.rival_code,
            host_description: match.rival_description
          )
          puts "<-- OK"
          unless match.result.nil?
            puts "--> Invert result"
            match.result.update(
              host_score: match.result.rival_score,
              host_penalties_score: match.result.rival_penalties_score,
              rival_score: match.result.host_score,
              rival_penalties_score: match.result.host_penalties_score,
            )
            puts "<-- OK"
          end
          puts "--> Invert Predictions"
          MatchPrediction.where(match_id: match.id).all.each do |prediction|
            prediction.update(host_score: prediction.rival_score, rival_score: prediction.host_score)
          end
          puts "<-- OK"
          puts "--> Invert Penalties Predictions"
          MatchPenaltiesPrediction.where(match_id: match.id).all.each do |prediction|
            prediction.update(host_score: prediction.rival_score, rival_score: prediction.host_score)
          end
          puts "<-- OK"
        end
      end
    end
  end
end

def load_files(dir)
  Dir[dir].each { |file| load file }
end
