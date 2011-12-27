class AddTalkOwner < ActiveRecord::Migration
  def up
    rename_column :users, :perm_admin, :perm_site_admin
    change_column :users, :perm_site_admin, :boolean, :default => 0
    add_column :talks, :owner_id, :int
  end

  def down
    change_column :users, :perm_site_admin, :boolean, :default => nil
    rename_column :users, :perm_site_admin, :perm_admin
    remove_column :talks, :owner_id
  end
end
