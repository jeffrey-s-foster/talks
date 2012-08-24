class AddKindToTalk < ActiveRecord::Migration
  def change
    add_column :talks, :kind, :string, :default => "standard", :null => false
  end
end
