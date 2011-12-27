class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :lists_talks, :id => false do |t|
      t.integer :list_id
      t.integer :talk_id

    end

    add_index :lists_talks, :list_id, :unique => true
    add_index :lists_talks, :talk_id, :unique => true
    add_index :talks, :start_time
  end
end
