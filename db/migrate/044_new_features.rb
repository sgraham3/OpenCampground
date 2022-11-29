class NewFeatures < ActiveRecord::Migration
  class DateFmt < ActiveRecord::Base; end
  def self.up
    add_column :options, :use_storage, :boolean, :default => false
    add_column :rates, :monthly_storage, :decimal, :precision => 11, :scale => 5, :default => 0.0
    add_column :reservations, :storage, :boolean, :default => false
    add_column :options, :use_closed, :boolean, :default => false
    add_column :options, :closed_start, :date
    add_column :options, :closed_end, :date
    add_column :date_fmts, :short_fmt, :string, :limit => 16
    [ {'name'=>'short',         'short_fmt' => "%b %d"},
      {'name'=>'natural',       'short_fmt' => "%B %d"},
      {'name'=>'iso_date',      'short_fmt' => "%m-%d"},
      {'name'=>'finnish',       'short_fmt' => "%d.%m"},
      {'name'=>'american',      'short_fmt' => "%m/%d"},
      {'name'=>'euro_24hr',     'short_fmt' => "%d %B"},
      {'name'=>'euro_24hr_ymd', 'short_fmt' => "%m.%d"},
      {'name'=>'italian',       'short_fmt' => "%d/%m"} ].each do |t|
        fmt = DateFmt.find_by_name(t['name'])
	fmt.update_attributes :short_fmt => t['short_fmt']
      end
  end

  def self.down
    remove_column :options, :use_storage
    remove_column :rates, :monthly_storage
    remove_column :reservations, :storage
    remove_column :options, :use_closed
    remove_column :options, :closed_start
    remove_column :options, :closed_end
    remove_column :date_fmts, :short_fmt
  end
end
