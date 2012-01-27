class AddSpeakerUrlToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :speaker_url, :text, :default => "", :null => false
  end
end
