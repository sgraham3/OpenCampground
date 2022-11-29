class CreateCardknoxPrompts < ActiveRecord::Migration
  def self.up
    unless Prompt.find_by_display 'CardKnox-payment'
      Prompt.create!(:display => 'CardKnox-payment',
		     :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'")
      Prompt.create!(:display => 'CardKnox-a-payment',
		     :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'<p>If you will not be paying now select Finish Reservation.")
    end
  end

  def self.down
    Prompt.all(:conditions => 'display like \'%CardKnox\'').each {|p| p.destroy}
    begin
      Prompt.create! :display => 'show', :body => 'deleted'
    rescue
    end
  end
end
