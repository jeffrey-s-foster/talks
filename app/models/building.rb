class Building < ActiveRecord::Base
  validates :abbrv, :uniqueness => true, :presence => true
end
