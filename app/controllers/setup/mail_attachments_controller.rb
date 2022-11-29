class Setup::MailAttachmentsController < ApplicationController

  def edit
    @page_title = 'Email Attachments'
    @id = params[:id]
    @mail_template = MailTemplate.find params[:id]
    @mail_attachments = MailAttachment.find_all_by_template_id(@id)
  end

  # PUT /setup_mail_attachments/1
  # PUT /setup_mail_attachments/1.xml
  def update
    unless params[:upload]
      flash[:error]= 'No Filename specified. Browse to find an attachment file'
      redirect_to edit_setup_mail_attachment_url(params[:id]) and return
    end

    @mail_template = MailTemplate.find(params[:id])
    @mail_attachment = MailAttachment.find_all_by_template_id(@id)

    name = sanitize_filename params[:upload].original_filename
    directory = "public/images"
    # create the file path
    path = File.join(directory, name)
    debug path
    unless File::exists? path
      # write the file
      if File.open(path, "wb") { |f| f.write(params[:upload].read) }
	flash[:notice] = "File upload succeeded"
      else
	flash[:error] = "File upload failed"
	raise
      end
    end
    MailAttachment.create :template_id => params[:id], :file_name => name
    redirect_to edit_setup_mail_attachment_url(params[:id])
  rescue => err
    flash[:error] = "File upload failed.  Did you select a file to upload?"
    error err.to_s
    redirect_to edit_setup_mail_attachment_url(params[:id])
  end

  # DELETE /setup_mail_attachments/1
  # DELETE /setup_mail_attachments/1.xml
  def destroy
    @mail_attachment = MailAttachment.find(params[:id])
    file_name = @mail_attachment.file_name
    template_id = @mail_attachment.template_id
    @mail_attachment.destroy
    users = MailAttachment.find_all_by_file_name file_name
    debug "found #{users.size} users of #{file_name}"
    if users.empty?
      begin
        path = File.join 'public/images', file_name
	if File::exists? path
	  if File::delete path
	    debug 'file delete succeeded: ' + file_name
	  else
	    flash[:error] = 'Error in file deletion'
            error 'Error deleting file: ' + filename
	  end
	end
      rescue => err
	flash[:error] = 'Error in file deletion ' + err.to_s
	error 'Error deleting file ' + err.to_s
      end
    end

    respond_to do |format|
      format.html { redirect_to(edit_setup_mail_attachment_url(template_id)) }
      format.xml  { head :ok }
    end
  rescue
    flash[:error] = 'Error in file deletion ' + err.to_s
    error 'Error deleting file ' + err.to_s
    redirect_to(edit_setup_mail_attachment_url(template_id))
  end
end
