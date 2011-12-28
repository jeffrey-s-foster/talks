class List < ActiveRecord::Base
  validates_presence_of :name

  has_and_belongs_to_many :talks
  has_and_belongs_to_many :owners, :foreign_key => "owned_list_id", :association_foreign_key => "owner_id", :join_table => "lists_owners"
  has_and_belongs_to_many :posters, :foreign_key => "poster_list_id", :association_foreign_key => "poster_id", :join_table => "lists_posters"
end
