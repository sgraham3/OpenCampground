class ManditoryExtras < ActiveRecord::Migration
  #############################################
  # enhance extras
  #   add capability to require an extra
  #   add capability to require an extra on remote
  #############################################
  def self.up
    add_column :extras, :required, :boolean, :default => false
    add_column :extras, :remote_required, :boolean, :default => false
  end

  def self.down
    remove_column :extras, :required
    remove_column :extras, :remote_required
  end
end
