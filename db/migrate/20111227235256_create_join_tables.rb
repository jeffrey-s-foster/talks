class CreateJoinTables < ActiveRecord::Migration
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

    create_table :lists_owners, :id => false do |t|
      t.integer :list_id
      t.integer :owner_id
    end

    create_table :lists_posters, :id => false do |t|
      t.integer :list_id
      t.integer :poster_id
    end

    add_index :lists_talks, :list_id
    add_index :lists_talks, :talk_id
    add_index :talks, :start_time
    add_index :lists_owners, :list_id
    add_index :lists_owners, :owner_id
    add_index :lists_posters, :list_id
    add_index :lists_posters, :poster_id
  end
end
