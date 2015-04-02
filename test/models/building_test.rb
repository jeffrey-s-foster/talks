require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @avw = buildings(:avw)
    @csic = buildings(:csic)
    @psc = buildings(:psc)
  end
  
  test "abbrv_and_name" do
    assert_equal "PSC", @psc.abbrv_and_name
    assert_equal "AVW - A.V. Williams Building", @avw.abbrv_and_name
  end
end
