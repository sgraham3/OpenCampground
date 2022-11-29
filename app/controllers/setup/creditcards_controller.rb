class Setup::CreditcardsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Creditcards
#####################################################
  def index
    @page_title = 'List of Payment Types'
    @creditcards = Creditcard.all
  end

  def sort
    @page_title = 'Update sort order of Payment Types'
    @creditcards = Creditcard.all
  end

  def resort
    pos = 1
    params[:creditcards].each do |id|
      Creditcard.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_creditcards_path
  end
      
  def new
    @page_title = 'Define a new Payment Type'
    @creditcard = Creditcard.new
  end

  def create
    @creditcard = Creditcard.new(params[:creditcard])
    if @creditcard.save
      flash[:notice] = "Payment Type #{@creditcard.name} was successfully created."
    else
      flash[:error] = 'Creation of new Payment Type failed. Make sure name is unique'
    end
    redirect_to setup_creditcards_path
  end

  def edit
    @page_title = 'Modify a current Payment Type'
    @creditcard = Creditcard.find(params[:id])
  end

  def update
    @creditcard = Creditcard.find(params[:id])
    if @creditcard.update_attributes(params[:creditcard])
      flash[:notice] = "Creditcard #{@creditcard.name} was successfully updated."
    else
      flash[:error] = 'Update of Payment Type failed.'
    end
    redirect_to setup_creditcards_path
  end

  def destroy
    creditcard = Creditcard.find(params[:id])
    name = creditcard.name
    pmt = Payment.find_all_by_creditcard_id(creditcard.id)
    if pmt.size == 0
        if creditcard.destroy
	flash[:notice] = "Payment Type #{name} was successfully destroyed."
      else
	flash[:error] = 'Deletion of Payment Type failed.'
      end
    else
      flash[:error] = "Payment Type #{name} in use by reservations: "
      pmt.each do |p|
        flash[:error] += p.reservation_id.to_s + ' '
      end
    end
    redirect_to setup_creditcards_path
  end
end
