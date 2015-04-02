class Building < ActiveRecord::Base
  validates :abbrv, :uniqueness => true, :presence => true

  def abbrv_and_name
    return abbrv if name == "" || name.nil?
    return "#{abbrv} - #{name}"
  end
end
