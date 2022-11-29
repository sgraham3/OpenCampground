class CleanupRes < ActiveRecord::Migration
  # remove a duplicated value
  def self.up
    remove_column :options, :use_remote_res
  rescue
    # ignore the error
  end

  def self.down
    add_column :options, :use_remote_res, :boolean
  rescue
    # ignore the error
  end
end
