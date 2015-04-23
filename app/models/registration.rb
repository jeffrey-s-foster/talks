class Registration < ActiveRecord::Base
  belongs_to :user, inverse_of: :registrations
  belongs_to :talk, inverse_of: :registrations
end
