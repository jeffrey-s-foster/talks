require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "abbrv_and_name" do
    assert_equal "PSC", buildings(:psc).abbrv_and_name
    assert_equal "AVW - A.V. Williams Building", buildings(:avw).abbrv_and_name
  end
end
