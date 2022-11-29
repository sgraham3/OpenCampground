class Setup::MailTemplatesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

  def index
    mt = MailTemplate.all(:conditions => 'name LIKE "reservation_%"')
    if @option.use_remote_reservations?
      @mail_templates = mt + MailTemplate.all(:conditions => 'name LIKE "remote_reservation_%"')
    else
      @mail_templates = mt
    end
    @mail_templates << MailTemplate.find_by_name('tst')
    @page_title = 'Email messages'
  end

  def edit
    logger.debug "MailTemplate:edit"
    @mail_template = MailTemplate.find(params[:id])
    @page_title = "Edit #{@mail_template.name} message"
  end

  def update
    @mail_template = MailTemplate.find(params[:id])

    if @mail_template.update_attributes(params[:mail_template])
      flash[:notice] = 'MailTemplate was successfully updated.'
    else
      flash[:notice] = 'MailTemplate update failed'
    end
    redirect_to setup_mail_templates_url
  end

end
