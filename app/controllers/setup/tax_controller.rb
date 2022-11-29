class Setup::TaxController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

############################################
#   Taxes
############################################
# There should only be one record in the 
# tax table so these methods will enforce
# that
############################################
  def show
    @page_title = 'Sales and Room taxes'
    unless @tax = Tax.first
      logger.info "show: no tax records found"
      redirect_to :action => 'new'
      return
    end
    logger.info "show: tax record found"
  rescue
    logger.error "error in Tax:show"
    flash[:error] = "Application error"
  end

  def new
    @page_title = 'Initial definition of Sales and Room taxes'
    if t = Tax.first
      logger.info "new: tax record found"
      flash[:warning] = 'Edit current tax table instead of creating a new one'
      redirect_to :action => 'edit'
      return
    end
    logger.info "new: no tax records found"
    @tax = Tax.new
  rescue
    logger.error "error in Tax:new"
    flash[:error] = "Application error"
  end

  def create
    @tax = Tax.new(params[:tax])
    if @tax.save
      flash[:notice] = 'Tax was successfully created.'
      redirect_to :action => 'show'
    else
      flash[:error] = 'Error creating tax table.  Table not created.'
      render :action => 'new'
    end
  rescue
    logger.error "error in Tax:create"
    flash[:error] = "Application error"
  end

  def edit
    @page_title = 'Edit Sales and Room taxes'
    @tax = Tax.first
  rescue
    logger.error "error in Tax:edit"
    flash[:error] = "Application error"
  end

  def update
    t1 = Tax.new(params[:tax])
    if tax = Tax.update(1,
			:room_tax_percent => t1.room_tax_percent,
                        :sales_tax_percent => t1.sales_tax_percent,
                        :local_tax_percent => t1.local_tax_percent,
                        :room_tax_amount => t1.room_tax_amount,
                        :rmt_apl_week => t1.rmt_apl_week,
                        :rmt_apl_month => t1.rmt_apl_month,
                        :st_apl_week => t1.st_apl_week,
                        :st_apl_month => t1.st_apl_month)
      flash[:notice] = 'Tax was successfully updated.'
      redirect_to :action => 'show'
    else
      flash[:error] = 'Tax record update failed.'
      render :action => 'edit'
    end
  rescue
    logger.error "error in Tax:update"
    flash[:error] = "Application error"
  end

end
