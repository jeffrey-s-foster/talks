class DefaultEmptyStrings < ActiveRecord::Migration
  def up
    change_column :lists, :name, :string, :default => ""
    change_column :lists, :short_descr, :text, :default => ""
    change_column :lists, :long_descr, :text, :default => ""
    change_column :users, :name, :string, :default => ""
  end

  def down
    change_column :lists, :name, :string, :default => nil
    change_column :lists, :short_descr, :text, :default => nil
    change_column :lists, :long_descr, :text, :default => nil
    change_column :users, :name, :string, :default => nil
  end
end
