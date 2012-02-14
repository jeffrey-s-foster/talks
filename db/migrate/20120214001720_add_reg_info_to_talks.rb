class AddRegInfoToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :reg_info, :text, :default => ""
  end
end
