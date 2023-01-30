require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    cs_with_most_customers = { id: 0, customers: 0}
    previous_cs_score = 0

    @customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) }
    @customer_success.sort_by! { |cs| cs[:score] }
    @customer_success.each do |cs|
      cs_customers = count_customers_by_cs(@customers, cs[:score], previous_cs_score)

      if cs_customers > cs_with_most_customers[:customers]
        cs_with_most_customers = { id: cs[:id], customers: cs_customers }
        previous_cs_score = cs[:score]
      end
    end

    cs_with_most_customers[:id]
  end

  def count_customers_by_cs(customers, cs_score, previous_cs_score)
    customers.count do |customer|
      (customer[:score] <= cs_score) && (customer[:score] > previous_cs_score)
    end
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  # def test_scenario_two
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([11, 21, 31, 3, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     []
  #   )
  #   assert_equal 0, balancer.execute
  # end

  # def test_scenario_three
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores(Array(1..999)),
  #     build_scores(Array.new(10000, 998)),
  #     [999]
  #   )
  #   result = Timeout.timeout(1.0) { balancer.execute }
  #   assert_equal 998, result
  # end

  # def test_scenario_four
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([1, 2, 3, 4, 5, 6]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     []
  #   )
  #   assert_equal 0, balancer.execute
  # end

  # def test_scenario_five
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 2, 3, 6, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     []
  #   )
  #   assert_equal 1, balancer.execute
  # end

  # def test_scenario_six
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 99, 88, 3, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     [1, 3, 2]
  #   )
  #   assert_equal 0, balancer.execute
  # end

  # def test_scenario_seven
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 99, 88, 3, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     [4, 5, 6]
  #   )
  #   assert_equal 3, balancer.execute
  # end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
