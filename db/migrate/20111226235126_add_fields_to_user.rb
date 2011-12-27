class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :perm_admin, :boolean
    add_column :users, :perm_create_talk, :boolean
  end
end
