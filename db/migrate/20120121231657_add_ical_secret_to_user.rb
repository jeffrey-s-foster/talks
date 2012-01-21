class AddIcalSecretToUser < ActiveRecord::Migration
  def change
    add_column :users, :ical_secret, :text
  end
end
