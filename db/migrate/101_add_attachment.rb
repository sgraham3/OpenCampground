class AddAttachment < ActiveRecord::Migration
  
  def self.up
    create_table :mail_attachments do |t|
      t.integer :template_id
      t.string  :file_name
      t.timestamps
    end
  end

  def self.down
    drop_table :mail_attachments
  end

end
