class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string :abbrv
      t.string :name
      t.text :url

      t.timestamps
    end

    add_column :talks, :building_id, :integer
    add_column :talks, :room, :text
  end
end
