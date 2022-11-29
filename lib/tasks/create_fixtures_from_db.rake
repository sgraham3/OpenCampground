namespace :db do
  namespace :fixtures do
    
#    thanks to saltzmanjoelh on rails forum for this task
    desc 'Create YAML test fixtures from data in an existing database.'
    # Defaults to development database.  Set RAILS_ENV to override.
    task :dump => :environment do
      sql  = "SELECT * FROM %s ORDER BY id"
      skip_tables = ["schema_info"]
      ActiveRecord::Base.establish_connection(:development)
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        i = "000"
        File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
	  begin
	    data = ActiveRecord::Base.connection.select_all("SELECT * FROM %s ORDER BY id" % table_name)
	  rescue
	    data = ActiveRecord::Base.connection.select_all("SELECT * FROM %s" % table_name)
	  end
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  end
end
