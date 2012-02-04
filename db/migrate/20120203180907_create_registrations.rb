class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :talk_id
      t.integer :user_id
      t.string :name
      t.string :email
      t.text :organization
      t.string :secret

      t.timestamps
    end

    add_column :talks, :request_reg, :boolean, :default => false
  end
end
