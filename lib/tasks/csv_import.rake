require 'csv'    

namespace :db do
  desc 'Load camper database from csv file'
  # Defaults to development database.  Set RAILS_ENV to override.

  filename = 'Campers.csv'

  task :load_campers_from_csv => :environment do 
    CSV.open(filename, 'r', ';') do |row|
      begin
	Camper.create!( :first_name => row[0],
			:last_name => row[1],
			:address2 => row[3],
			:address => row[2],
			:city => row[4],
			:state => row[5],
			:mail_code => row[6],
			:phone => row[7],
			:phone_2 => row[8],
			:email => row[9],
			:idnumber => row[10],
			:activity => Date.today)
      rescue
        $stderr.puts "error in input row: \'#{row}\'"
      end
    end
  end
end
