class AddOrgToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organization, :text, :deafult => ""
  end
end
