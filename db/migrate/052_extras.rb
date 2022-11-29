class Extras < ActiveRecord::Migration
  def self.up
    add_column :extra_charges, :measured_rate, :decimal, :precision => 10, :scale => 4, :default => 0.0
    extra = Extra.all
    extra.each do |ex|
      if (ex.extra_type == Extra::MEASURED)
	ExtraCharge.all(:conditions => ["extra_id = ?", ex.id]).each do |e|
	  e.update_attribute :measured_rate, ex.rate
	end
      end
    end
  end

  def self.down
    remove_column :extra_charges, :measured_rate
  end
end
