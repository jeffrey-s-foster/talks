class AddBioToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :bio, :text, :default => "", :null => false
  end
end
