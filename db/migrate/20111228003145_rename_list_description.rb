class RenameListDescription < ActiveRecord::Migration
  def up
    rename_column :lists, :description, :short_descr
    add_column :lists, :long_descr, :text
  end

  def down
    rename_column :lists, :short_descr, :description
    remove_column :lists, :long_descr
  end
end
