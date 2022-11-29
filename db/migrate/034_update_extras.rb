class UpdateExtras < ActiveRecord::Migration
  def self.up
    add_column :extras, :extra_type, :integer, :default => 0
    rename_column :extras, :onetime_charge, :charge
    Extra.all.each do |e|
      say "counted = #{e.counted}, measured = #{e.measured}, onetime = #{e.onetime}"
      if e.measured?
	say 'MEASURED'
	e.update_attribute :extra_type, Extra::MEASURED
      elsif e.counted?
        say 'COUNTED'
	e.update_attribute :extra_type, Extra::COUNTED
      elsif e.onetime?
	say 'OCCASIONAL'
	e.update_attribute :extra_type, Extra::OCCASIONAL
      else
	say 'STANDARD'
	e.update_attribute :extra_type, Extra::STANDARD
      end
    end
  rescue
  end

  def self.down
    rename_column :extras, :charge, :onetime_charge
    Extra.all.each do |e|
      case e.extra_type
	when Extra::MEASURED
	  e.measured = true
	when Extra::COUNTED
	  e.counted = true
	when Extra::OCCASIONAL
	  e.onetime = true
      end
    end
    remove_column :extras, :extra_type
  end
end
