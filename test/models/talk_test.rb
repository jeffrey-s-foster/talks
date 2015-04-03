require 'test_helper'

class TalkTest < ActiveSupport::TestCase

  test "validations" do
    assert talks(:talk_1).valid?
    assert talks(:talk_minimal).valid?
    assert talks(:talk_start_end_different_days).invalid?
    assert talks(:talk_no_start).invalid?
    assert talks(:talk_no_end).invalid?
    assert talks(:talk_start_before_end).invalid?
    assert talks(:talk_no_owner).invalid?
    assert talks(:talk_no_list).invalid?
  end
  
end
