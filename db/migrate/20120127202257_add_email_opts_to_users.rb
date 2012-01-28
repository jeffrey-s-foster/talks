class AddEmailOptsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :opt_email_today, :boolean, :default => true, :null => false
    add_column :users, :opt_email_this_week, :boolean, :default => true, :null => false
  end
end
