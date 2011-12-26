class CreateTalks < ActiveRecord::Migration
  def change
    create_table :talks do |t|
      t.text :title, :default => ""
      t.text :abstract, :default => ""
      t.text :speaker, :default => ""
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
