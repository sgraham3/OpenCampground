class ChangeSize < ActiveRecord::Migration
  def self.up
    change_column :integrations,  :pp_business,  :string,  :limit => 128
  end

  def self.down
    change_column :integrations,  :pp_business,  :string,  :limit => 32
  end
end
