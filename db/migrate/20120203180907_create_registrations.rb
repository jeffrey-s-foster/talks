class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :talk_id
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :organization

      t.timestamps
    end

    add_column :talks, :request_reg, :boolean, :default => false
  end
end
