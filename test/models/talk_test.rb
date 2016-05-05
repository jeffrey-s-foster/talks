require 'test_helper'

class TalkTest < ActiveSupport::TestCase

  test "validations" do
    assert talks(:talk_11).valid?
    assert talks(:talk_minimal).valid?

    talk_start_end_different_days = Talk.new(
      start_time: "2015-01-01 23:00:00 -5",
      end_time: "2015-01-02 00:00:00 -5",
      owner: users(:user_admin),
      lists: [lists(:list_0)]
    )
    assert talk_start_end_different_days.invalid?

    talk_no_start = Talk.new(
      end_time: "2015-01-01 11:00:00 -5",
      owner: users(:user_admin),
      lists: [lists(:list_0)]
    )
    assert talk_no_start.invalid?

    talk_no_end = Talk.new(
      start_time: "2015-01-01 10:00:00 -5",
      owner: users(:user_admin),
      lists: [lists(:list_0)]
    )
    assert talk_no_end.invalid?

    talk_start_before_end = Talk.new(
      start_time: "2015-01-01 11:00:00 -5",
      end_time: "2015-01-01 10:00:00 -5",
      owner: users(:user_admin),
      lists: [lists(:list_0)]
    )
    assert talk_start_before_end.invalid?

    talk_no_owner = Talk.new(
      start_time: "2015-01-01 10:00:00 -5",
      end_time: "2015-01-01 11:00:00 -5",
      lists: [lists(:list_0)])
    assert talk_no_owner.invalid?

    talk_no_list = Talk.new(
      start_time: "2015-01-01 10:00:00 -5",
      end_time: "2015-01-01 11:00:00 -5",
      owner: users(:user_admin)
    )
    assert talk_no_list.invalid?
  end

  test "extended title" do
    assert_equal "Title 11", talks(:talk_11).extended_title
  end

  test "subscription" do
    assert_equal nil, talks(:talk_11).subscription(users(:user_plain))
    assert_equal subscriptions(:s_six), talks(:talk_minimal).subscription(users(:user_list_subscriber))
  end

  test "subscriber-watcher?" do
    assert_not talks(:talk_11).subscriber?(users(:user_plain))
    assert_not talks(:talk_11).watcher?(users(:user_plain))
    assert talks(:talk_minimal).subscriber?(users(:user_list_subscriber))
    assert_not talks(:talk_minimal).watcher?(users(:user_list_subscriber))
    assert_not talks(:talk_11).subscriber?(users(:user_list_subscriber)) # not transitively through lists
    assert_not talks(:talk_31).watcher?(users(:user_list_subscriber)) # not transitively through lists
  end

  test "registered?" do
    assert_not talks(:talk_12).registered?(users(:user_plain))
    assert talks(:talk_10).registered?(users(:user_plain))
    assert_not talks(:talk_13).registered?(users(:user_plain))
  end

  test "through" do
    assert_equal Hash.new, talks(:talk_10).through(nil)
    h1 = {:subscriber => [lists(:list_1)]}
    assert_equal h1, talks(:talk_10).through(users(:user_list_subscriber))
    h2 = {:watcher => [lists(:list_3)]}
    assert_equal h2, talks(:talk_30).through(users(:user_list_subscriber))
  end


  test "time" do
    # All time tests are done in UTC to avoid having tests break
    # when daylight savings time begins or ends.
    old_zone = Time.zone
    Time.zone = 'UTC'
    travel_to Time.parse("2015-04-22 12:00:00 UTC") do
      assert     talks(:talk_past).past?
      assert_not talks(:talk_past).upcoming?
      assert_not talks(:talk_past).current?
      assert_not talks(:talk_past).today?
      assert_not talks(:talk_past).this_week?
      assert_not talks(:talk_past).later_this_week?
      assert_not talks(:talk_past).next_week?
      assert_not talks(:talk_past).further_ahead?

      assert_not talks(:talk_upcoming).past?
      assert     talks(:talk_upcoming).upcoming?
      assert     talks(:talk_upcoming).current?
      assert     talks(:talk_upcoming).today?
      assert     talks(:talk_upcoming).this_week?
      assert     talks(:talk_upcoming).later_this_week? # slightly odd defn, but would need to check a lot of logic before changing
      assert_not talks(:talk_upcoming).next_week?
      assert_not talks(:talk_upcoming).further_ahead?

      assert_not talks(:talk_current).past?
      assert     talks(:talk_current).upcoming?
      assert     talks(:talk_current).current?
      assert_not talks(:talk_current).today?
      assert     talks(:talk_current).this_week?
      assert     talks(:talk_current).later_this_week?
      assert_not talks(:talk_current).next_week?
      assert_not talks(:talk_current).further_ahead?

      assert_not talks(:talk_today).past?
      assert_not talks(:talk_today).upcoming?
      assert     talks(:talk_today).current?
      assert     talks(:talk_today).today?
      assert     talks(:talk_today).this_week?
      assert     talks(:talk_today).later_this_week?
      assert_not talks(:talk_today).next_week?
      assert_not talks(:talk_today).further_ahead?

      assert     talks(:talk_this_week).past?
      assert_not talks(:talk_this_week).upcoming?
      assert_not talks(:talk_this_week).current?
      assert_not talks(:talk_this_week).today?
      assert     talks(:talk_this_week).this_week?
      assert_not talks(:talk_this_week).later_this_week?
      assert_not talks(:talk_this_week).next_week?
      assert_not talks(:talk_this_week).further_ahead?

      assert_not talks(:talk_later_this_week).past?
      assert     talks(:talk_later_this_week).upcoming?
      assert     talks(:talk_later_this_week).current?
      assert_not talks(:talk_later_this_week).today?
      assert     talks(:talk_later_this_week).this_week?
      assert     talks(:talk_later_this_week).later_this_week?
      assert_not talks(:talk_later_this_week).next_week?
      assert_not talks(:talk_later_this_week).further_ahead?

      assert_not talks(:talk_next_week).past?
      assert     talks(:talk_next_week).upcoming?
      assert     talks(:talk_next_week).current?
      assert_not talks(:talk_next_week).today?
      assert_not talks(:talk_next_week).this_week?
      assert_not talks(:talk_next_week).later_this_week?
      assert     talks(:talk_next_week).next_week?
      assert_not talks(:talk_next_week).further_ahead?

      assert_not talks(:talk_further_ahead).past?
      assert     talks(:talk_further_ahead).upcoming?
      assert     talks(:talk_further_ahead).current?
      assert_not talks(:talk_further_ahead).today?
      assert_not talks(:talk_further_ahead).this_week?
      assert_not talks(:talk_further_ahead).later_this_week?
      assert_not talks(:talk_further_ahead).next_week?
      assert     talks(:talk_further_ahead).further_ahead?
    end
    Time.zone = old_zone
  end
end
