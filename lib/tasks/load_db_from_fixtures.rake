namespace :db do
  desc 'Load fixtures from db directory into development database.'

  task :load_db_from_fixtures => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(Rails.env)
    fixtures_dir = File.join(Rails.root, "db")
    Dir.glob(File.join(fixtures_dir, '*.{yml,csv}')).each do |fixture_file|
      Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
    end
  end
end
