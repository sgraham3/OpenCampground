class Extra < ActiveRecord::Base; default_scope ; end

class ChangeToTaxrates < ActiveRecord::Migration

  ######################
  # we have to extract the data,
  # change the column type and then
  # restore the data
  ######################
  def self.change_col_to_decimal(tbl, col)
    value=[]
    data=[]
    # klass = Object.const_get(tbl.to_s.capitalize.chop!.to_sym).new
    # table = tbl.to_s.capitalize.chop.delete('_').to_sym
    table = tbl.to_s.camelcase.chop.to_sym
    klass = Object.const_get(table)
    col_sym = col.to_sym

    # build an array of the column we are interested in
    data = klass.find :all
    data.each do |d|
      value << d.send(col_sym)
    end

    # now change the column and tell active record
    change_column tbl, col, :decimal, :precision => 6, :scale => 2, :default => 0.0
    klass.reset_column_information

    # restore the data and change it 
    # to float divided by 100
    # and save it
    value.each_index do |i|
      data[i].update_attribute( col_sym, value[i]/100.0)
    end
  end

  def self.up
    create_table "taxrates" do |t|
      t.column "name",          :string,  :limit => 16
      t.column "is_percent",	:boolean, :default => false
      t.column "percent",       :float,                :default => 0.0
      t.column "amount",        :decimal, :precision => 6, :scale => 2, :default => 0.0
      t.column "apl_week",      :boolean,              :default => false
      t.column "apl_month",     :boolean,              :default => false
    end
    tax = Tax.find :first
    if tax.sales_tax_percent > 0.0
      t = Taxrate.new :name => "Sales Tax",
                      :is_percent => true,
		      :percent => tax.sales_tax_percent,
		      :apl_week => tax.st_apl_week,
		      :apl_month => tax.st_apl_month
      t.save
    end
    if tax.local_tax_percent > 0.0
      t = Taxrate.new :name => "Local Tax",
                      :is_percent => true,
		      :percent => tax.local_tax_percent,
		      :apl_week => tax.lt_apl_week,
		      :apl_month => tax.lt_apl_month
      t.save
    end
    if tax.room_tax_percent > 0.0
      t = Taxrate.new :name => "Room Tax",
                      :is_percent => true,
		      :percent => tax.room_tax_percent,
		      :apl_week => tax.rmt_apl_week,
		      :apl_month => tax.rmt_apl_month
      t.save
    end
    if tax.room_tax_amount > 0
      t = Taxrate.new :name => "Room Tax",
                      :is_percent => false,
		      :amount => tax.room_tax_amount/100.0,
		      :apl_week => tax.rmt_apl_week,
		      :apl_month => tax.rmt_apl_month
      t.save
    end
    add_column "reservations", "tax_str", :text
    add_column "reservations", "taxes",   :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column "archives", "tax_str", :text


    change_col_to_decimal :reservations, :deposit
    change_col_to_decimal :reservations, :total_charge
    change_col_to_decimal :reservations, :total
    change_col_to_decimal :reservations, :daily_rate
    change_col_to_decimal :reservations, :daily_disc
    change_col_to_decimal :reservations, :day_charges
    change_col_to_decimal :reservations, :weekly_rate
    change_col_to_decimal :reservations, :weekly_disc
    change_col_to_decimal :reservations, :week_charges
    change_col_to_decimal :reservations, :monthly_rate
    change_col_to_decimal :reservations, :monthly_disc
    change_col_to_decimal :reservations, :month_charges
    change_col_to_decimal :archives, :deposit
    change_col_to_decimal :archives, :total_charge
    change_col_to_decimal :extra_charges, :daily_charges
    change_col_to_decimal :extra_charges, :weekly_charges
    change_col_to_decimal :extra_charges, :monthly_charges
    change_col_to_decimal :extras, :daily
    change_col_to_decimal :extras, :weekly
    change_col_to_decimal :extras, :monthly
    change_col_to_decimal :rates, :weekly_rate
    change_col_to_decimal :rates, :daily_rate
    change_col_to_decimal :rates, :monthly_rate
    Reservation.reset_column_information
    Archive.reset_column_information
    ExtraCharge.reset_column_information
    Extra.reset_column_information
    Rate.reset_column_information
    # recalculate charges
    Reservation.find(:all).each do |r|
      r.get_charges(Charge.new(r.startdate, r.enddate, r.space.price.id, r.discount.id, r.id))
      if r.save
	say "Reservation for #{r.camper.full_name} was successfully updated."
      else
	say 'Problem updating reservation'
      end
    end
  end

  def self.down
    drop_table "taxrates"
    remove_column "reservations", "tax_str"
    remove_column "reservations", "taxes"
    remove_column "archives", "tax_str"
  end
end
