require 'minitest/autorun'
require 'timeout'
require_relative '../../lib/customer-success/customer_success_balancing'

# rubocop:disable Metrics/ClassLength
class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_lowest_cs_score_by_customer
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 20, 30]),
      build_scores([60, 80]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_all_empty_return_no_cs
    balancer = CustomerSuccessBalancing.new(
      [],
      [],
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_one_cs_with_multiple_customers
    balancer = CustomerSuccessBalancing.new(
      build_scores([100]),
      build_scores([10, 20, 30, 40, 50, 60, 70, 80, 90, 100]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_cs_available_but_no_customer
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 21, 32]),
      [],
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_cs_have_no_score_duplicate
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_cs_is_positive
    balancer = CustomerSuccessBalancing.new(
      build_scores([-60, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_customer_is_positive
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 60, 95, 75]),
      build_scores([90, 20, -70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_away_cs_is_positive
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, -4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_cs_is_not_zero
    balancer = CustomerSuccessBalancing.new(
      build_scores([0, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_customer_is_not_zero
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 60, 95, 75]),
      build_scores([0, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_away_cs_is_not_zero
    balancer = CustomerSuccessBalancing.new(
      build_scores([90, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 0]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_cs_is_less_than1000
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..1_000)),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_customer_is_less_than1000000
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 60, 95, 75]),
      build_scores(Array(1_000_000.times { 1 })),
      [2, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_away_cs_is_a_existent_cs
    balancer = CustomerSuccessBalancing.new(
      build_scores([90, 60, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [1, 5]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_away_cs_is_no_less_than_cs_divided_by_2_round_down
    balancer = CustomerSuccessBalancing.new(
      build_scores([90, 60, 95, 75, 12]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 3, 4]
    )
    assert_equal(-1, balancer.execute)
  end

  def test_stress
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(999_999) { 1 }),
      Array(1..499)
    )
    assert_equal 500, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: }
    end
  end
end
# rubocop:enable Metrics/ClassLength
