class List < ActiveRecord::Base
  has_and_belongs_to_many :talks
  has_and_belongs_to_many :owners, :foreign_key => "owned_list_id", :class_name => "User"
  has_and_belongs_to_many :posters, :foreign_key => "poster_list_id", :class_name => "User"
end
