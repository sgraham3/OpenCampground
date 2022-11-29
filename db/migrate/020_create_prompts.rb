class CreatePrompts < ActiveRecord::Migration
  def self.up
    create_table :prompts do |t|
      t.string :display
      t.string :locale, :limit => 16, :default => 'en'
      t.text :body
      t.timestamps
    end
    Prompt.create!(:display => 'confirmation',
                         :body =>"This page is your reservation confirmation.  Print it on a printer or to a file for your records.")
    Prompt.create!(:display => 'find_space',
                         :body =>"On this page are listed all of the sites that are available on the dates you selected.\n   
			 The EWS column indicates whether the sites have Electricity, Water and Sewer and for those having Electricity the amp capacity.
			 The size column indicates the size in the common measure of the locale (normally feet or meters depending on the locale).
			 Daily, Weekly and Monthly columns give the Daily, Weekly and Monthly rate for the space.  
			 If there is no amount indicated the space does not have a rate for that period.
			 Type is the space type which was selected on the previous page.
			 The Special column contains information that may help you in deciding whether or not you would like the site.
			 <p>
			 When you find the site you want just click on the <span style=\"text-decoration: underline\">Select</span> link to the right of that site.
			 You will have an opportunity to change your selection on a following page if you change your mind.
			 There is a <em>Cancel</em> button at the bottom of the page.")
    Prompt.create!(:display => 'index',
                         :body =>"Using this series of web pages you can make your own reservations.  Just enter into the fields the information on your party. 
			   The most important piece of information is the dates you want.
			     When you have entered the requested information, pressing the \'Find Space\' button will cause the system to find spaces which are
			       available on the dates indicated.  At any time you can terminate the process with the \'Cancel\' button.")
    Prompt.create!(:display => 'show',
                         :body =>"This is your last chance to change things before you confirm your reservation and go to PayPal to pay for your stay. 
			 Any fields that are boxed can be modified by selecting them and typing the new data.
			 To change date or space select the buttons so labeled.
			 <p> 
			 Select the <em>Complete Reservation and Pay</em> button to go to PayPal to pay for your stay.  On PayPal you can use your PayPal account to pay or you can select the <em>guest</em> option to pay with a credit or debit card.
			 When your PayPal transaction is complete you will be checked in to your site if your reservation starts today.
			 A confirmation page will be presented which you can print for your records.")
    Prompt.create!(:display => 'wait_for_confirm',
			 :body => "This page is shown while we are waiting for PayPal to respond with a confirmation of the transaction.
			 This usually only takes a few seconds.
			 When the transaction is complete the confirmation page will be presented.")

  end

  def self.down
    drop_table :prompts
  end
end
