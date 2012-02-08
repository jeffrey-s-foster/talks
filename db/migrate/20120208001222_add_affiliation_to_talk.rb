class AddAffiliationToTalk < ActiveRecord::Migration
  def change
    add_column :talks, :speaker_affiliation, :text, :default => ""
  end
end
