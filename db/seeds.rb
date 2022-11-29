    Country.create!(:name => ' ')
    Creditcard.create!(:name => 'cash')
    Discount.create!(:name => 'none')
    Rigtype.create!(:name => 'other')
    Option.create!(
      :use_country => 'false',
      :use_recommend => 'false',
      :res_list_sort => "unconfirmed_remote desc, startdate, group_id, spaces.position asc",
      :inpark_list_sort => "unconfirmed_remote desc, enddate, startdate, group_id, spaces.position asc",
      :current_version => OC_RELEASE,
      :current_revision => OC_VERSION,
      :ftp_server => 'ocsrv.net',
      :ftp_account => 'anonymous',
      :ftp_passwd => 'opencampground')
    Sitetype.create!(:name => 'basic')
    Season.create! :name => "default", :startdate => Date.new(2000,1,1).to_s, :enddate => Date.new(2100,1,1).to_s
    User.create! :name => 'manager', :password => 'secret', :password_confirmation => 'secret', :admin => true
    Recommender.create! :name => 'none'
    [ {'name' => 'none'},
      {'name' => 'plain'},
      {'name' => 'login'},
      {'name' => 'cram_md5'} ].each { |e| SmtpAuthentication.create! e }

    MailTemplate.create!(:name => "reservation_confirmation",
			 :body => "Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  You are scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}.\n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "reservation_update",
			 :body => "Dear {{camper}},\n\nYour reservation at My RV Park has been updated.  You are now scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}.\n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "reservation_feedback",
			 :body => "Dear {{camper}},\n\nThank you for staying at My RV Park.\n\nPlease reply to this message and tell us how you enjoyed your stay and if there is anything we could do to make your next stay with us more enjoyable.\n\nWe enjoyed having your company\nTy Coon\nManager")
    MailTemplate.create!(:name => "remote_reservation_received",
			 :body =>"Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  Your reservation will be reviewed by the management and you will sent a confirmation.  \n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "remote_reservation_confirmation",
			 :body =>"Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  You are scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}. \n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "remote_reservation_reject",
			 :body =>"Dear {{camper}},\n\nYour reservation for arrival on {{start}} and departure on {{departure}} has not been confirmed.  Please call us at (111) 555-1212 to resolve the problems.  \n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "reservation_cancel",
			 :body => "Dear {{camper}},\n\nYour reservation {{number}} for {{start}} to {{departure}} has been canceled..  The reason for the cancellation is: {{reason}}.\n\nWe look forward to serving you in the future.\nManager")
    MailTemplate.create!(:name => "tst",
			 :body => "This is a test message")
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
			 You will have an opportunity to change your selection on a following page if you change your mind.")
    Prompt.create!(:display => 'index',
		   :body =>"Using this series of web pages you can make your own reservations.  Just enter into the fields the information on your party. 
			   The most important piece of information is the dates you want.
			     When you have entered the requested information, pressing the \'Find Space\' button will cause the system to find spaces which are
			       available on the dates indicated.  At any time you can terminate the process with the \'Cancel\' button.")
    Prompt.create!(:display => 'show',
		   :body =>"This is your last chance to change things before you confirm your reservation pay for your stay. 
			 Any fields that are boxed can be modified by selecting them and typing the new data.
			 To change date or space select the buttons so labeled.
			 <p> 
			 Select the <em>Complete Reservation</em> button to go to the page to pay for your stay. 
			 When your payment transaction is complete you will be checked in to your site if your reservation starts today.
			 A confirmation page will be presented which you can print for your records.
			 </p><p>
			 <b>This display will only persist for 30 minutes.  You must complete your reservation in that time</b>")
    Prompt.create!(:display => 'wait_for_confirm',
		   :body => "This page is shown while we are waiting for PayPal to respond with a confirmation of the transaction.
			 This usually only takes a few seconds.
			 When the transaction is complete the confirmation page will be presented.")
    Prompt.create!(:display => 'find_remote',
		   :body =>"On this page enter your name etc. Any fields with a asterisk after the name of the field are required.
			   You will not be able to proceed any further in the process until you have filled in the information required.")
    Prompt.create!(:display => 'CardConnect-payment',
 		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'")
    Prompt.create!(:display => 'CardConnect-a-payment',
		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'<p>If you will not be paying now select Finish Reservation.")
    Prompt.create!(:display => 'CardKnox-payment',
                   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'")
    Prompt.create!(:display => 'CardKnox-a-payment',
                   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'<p>If you will not be paying now select Finish Reservation.")
    Prompt.create!(:display => 'PayPal-payment',
		   :body =>"Review the amount to be charged using PayPal and then select the PayPal Buy Now button.  This button will take you to the PayPal secure payments page.")
    Prompt.create!(:display => 'PayPal-a-payment',
		   :body =>"Review the amount to be charged using PayPal and then select the PayPal Buy Now button.  This button will take you to the PayPal secure payments page.<p>If you will not be paying now select Finish Reservation.")

    [ {:name => 'body', :value => 'Black'},
      {:name => 'body_background', :value => 'WhiteSmoke'},
      {:name => 'main', :value => 'Black'},
      {:name => 'main_background', :value => 'WhiteSmoke'},
      {:name => 'columns', :value => 'Black'},
      {:name => 'columns_background', :value => 'LightSteelBlue'},
      {:name => 'banner', :value => 'Black'},
      {:name => 'banner_background', :value => 'MediumSlateBlue'},
      {:name => 'late', :value => 'Black'},
      {:name => 'late_background', :value => 'Yellow'},
      {:name => 'locale', :value => 'Black'},
      {:name => 'locale_background', :value => 'White'},
      {:name => 'occupied', :value => 'Black'},
      {:name => 'occupied_background', :value => 'LimeGreen'},
      {:name => 'overstay', :value => 'Black'},
      {:name => 'overstay_background', :value => 'LightGray'},
      {:name => 'reserved', :value => 'Black'},
      {:name => 'reserved_background', :value => 'LightSteelBlue'},
      {:name => 'today', :value => 'Red'},
      {:name => 'today_background', :value => 'Khaki'},
      {:name => 'notice', :value => 'Green'},
      {:name => 'notice_background', :value => 'Snow'},
      {:name => 'error', :value => 'Red'},
      {:name => 'error_background', :value => 'Snow'},
      {:name => 'warning', :value => 'Yellow'},
      {:name => 'warning_background', :value => 'Snow'},
      {:name => 'user', :value => 'Black'},
      {:name => 'unavailable', :value => 'Red'},
      {:name => 'unconfirmed', :value => 'Blue'},
      {:name => 'this_day', :value => 'Red'},
      {:name => 'link', :value => 'Black'},
      {:name => 'payment_due', :value => 'Red'},
      {:name => 'ip_editor_field_background', :value => 'White'},
      {:name => 'hover', :value => 'LightGrey'},
      {:name => 'explain_background', :value => 'White'} ].each {|c| Color.create! c}

    Version.create!(:release => '1.11',
		    :revision => '1344',
		    :description => 'revision for release 1.11')
