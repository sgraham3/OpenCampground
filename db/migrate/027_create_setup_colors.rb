class CreateSetupColors < ActiveRecord::Migration
  def self.up
    create_table :colors do |t|
      t.string :name
      t.string :value
    end
    Color.create!(:name => 'body', :value => 'Black')
    Color.create!(:name => 'body_background', :value => 'WhiteSmoke')
    Color.create!(:name => 'main', :value => 'Black')
    Color.create!(:name => 'main_background', :value => 'WhiteSmoke')
    Color.create!(:name => 'columns', :value => 'Black')
    Color.create!(:name => 'columns_background', :value => 'LightSteelBlue')
    Color.create!(:name => 'banner', :value => 'Black')
    Color.create!(:name => 'banner_background', :value => 'MediumSlateBlue')
    Color.create!(:name => 'late', :value => 'Black')
    Color.create!(:name => 'late_background', :value => 'Yellow')
    Color.create!(:name => 'locale', :value => 'Black')
    Color.create!(:name => 'locale_background', :value => 'White')
    Color.create!(:name => 'occupied', :value => 'Black')
    Color.create!(:name => 'occupied_background', :value => 'LimeGreen')
    Color.create!(:name => 'overstay', :value => 'Black')
    Color.create!(:name => 'overstay_background', :value => 'LightGray')
    Color.create!(:name => 'reserved', :value => 'Black')
    Color.create!(:name => 'reserved_background', :value => 'LightSteelBlue')
    Color.create!(:name => 'today', :value => 'Red')
    Color.create!(:name => 'today_background', :value => 'Khaki')

    Color.create!(:name => 'notice', :value => 'Green')
    Color.create!(:name => 'notice_background', :value => 'Snow')
    Color.create!(:name => 'error', :value => 'Red')
    Color.create!(:name => 'error_background', :value => 'Snow')
    Color.create!(:name => 'warning', :value => 'Yellow')
    Color.create!(:name => 'warning_background', :value => 'Snow')

    Color.create!(:name => 'user', :value => 'Black')
    Color.create!(:name => 'unavailable', :value => 'Red')
    Color.create!(:name => 'unconfirmed', :value => 'Blue')
    Color.create!(:name => 'this_day', :value => 'Red')
    Color.create!(:name => 'link', :value => 'Black')
    Color.create!(:name => 'payment_due', :value => 'Red')
    Color.create!(:name => 'ip_editor_field_background', :value => 'White')
    Color.create!(:name => 'explain_background', :value => 'White')
  end

  def self.down
    drop_table :colors
  end
end
