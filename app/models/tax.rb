class Tax < ActiveRecord::Base
  set_table_name "taxes"
  belongs_to :reservation
  include MyLib

  def self.combine(res_id)
    taxes = Tax.all :conditions => "reservation_id = #{res_id}", :order => "name"
    # taxes is an array of Tax
    ActiveRecord::Base.logger.debug "got #{taxes.size} tax records"
    taxes.each_index do |i|
      print i
      ActiveRecord::Base.logger.debug "record #{i} is #{taxes[i].id}"
      next if i == 0
      if taxes[i].name == taxes[i-1].name
        # we will combine i and i-1
	ActiveRecord::Base.logger.debug "combine #{taxes[i].id} with #{taxes[i - 1].id}"
	ActiveRecord::Base.logger.debug "amounts are #{taxes[i].amount} and #{taxes[i - 1].amount}"
	amount = taxes[i].amount + taxes[i - 1].amount
	ActiveRecord::Base.logger.debug "amount is now #{amount}"
	taxes[i].update_attributes :amount => amount
	ActiveRecord::Base.logger.debug "now destroying #{taxes[i - 1].id}"
	taxes[i - 1].destroy
      end
    end
  end
end
