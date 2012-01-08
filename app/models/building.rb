class Building < ActiveRecord::Base
  validates :abbrv, :uniqueness => true, :presence => true

  def abbrv_and_name
    return "#{abbrv} - #{name}" if name != ""
    return abbrv
  end
end
