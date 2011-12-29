class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :lists_subscribers, :id => false do |t|
      t.integer :subscribed_list_id
      t.integer :subscriber_id
    end

    add_index :lists_subscribers, :subscribed_list_id
    add_index :lists_subscribers, :subscriber_id
  end
end
