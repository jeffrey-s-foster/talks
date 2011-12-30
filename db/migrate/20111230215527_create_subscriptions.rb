class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :subscribable_id
      t.string :subscribable_type
      t.integer :user_id
      t.string :kind

      t.timestamps
    end

    add_index :subscriptions, :subscribable_id
    add_index :subscriptions, :subscribable_type
    add_index :subscriptions, :user_id
  end
end
