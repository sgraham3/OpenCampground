class CreateVersions < ActiveRecord::Migration
  class Option < ActiveRecord::Base; end

  def self.up
    create_table :versions do |t|
      t.string :release
      t.string :revision
      t.text :description
    end

    Version.create!(:release => '1.11',
		    :revision => '1036',
		    :description => 'revision for release 1.11')

    add_column :options, :current_version, :string
    add_column :options, :current_revision, :string
    add_column :options, :ftp_server, :string
    add_column :options, :ftp_account, :string
    add_column :options, :ftp_passwd, :string

    Option.first.update_attributes :current_version => '1.11',
				   :current_revision => '1036'

  end

  def self.down
    drop_table :versions
    remove_column :options, :current_version
    remove_column :options, :current_revision
    remove_column :options, :ftp_server
    remove_column :options, :ftp_account
    remove_column :options, :ftp_passwd
  end
end
