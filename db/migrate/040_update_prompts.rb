class UpdatePrompts < ActiveRecord::Migration
  def self.up
    Prompt.create!(:display => 'find_remote',
                         :body =>"On this page enter your name etc. Any fields with a asterisk after the name of the field are required. You will not be able to proceed any further in the process until you have filled in the information required.")
  end

  def self.down
    Prompt.find_by_name("find_remote").destroy
  end
end
