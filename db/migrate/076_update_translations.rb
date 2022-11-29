class UpdateTranslations < ActiveRecord::Migration
  def self.up
    add_column :options,  :date_format,  :string,  :limit => 12
    remove_column :options, :date_fmt_id
    drop_table :date_fmts
  end

  def self.down
    add_column "options", "date_fmt_id", :integer, :default => 1
    create_table :date_fmts do |t|
      t.string "name",      :limit => 32
      t.string "fmt",       :limit => 16
      t.string "short_fmt", :limit => 16
    end
  end
end
