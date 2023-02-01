class CustomerSuccessBalancingValidator
  def validate(customer_success, customers, away_customer_success)
    inputs_are_valid(customer_success, customers, away_customer_success)
  end

  private

  def inputs_are_valid(customer_success, customers, away_customer_success)
    customer_success_are_valid?(customer_success) &&
      customers_are_valid?(customers) &&
      away_customer_success_are_valid?(away_customer_success, customer_success)
  end

  def customer_success_are_valid?(customer_success)
    customer_success_scores = scores(customer_success)

    no_score_duplicates?(customer_success_scores) &&
      non_zero_positive?(customer_success_scores) &&
      score_is_less_than(1_000, customer_success_scores)
  end

  def customers_are_valid?(customers)
    customers_scores = scores(customers)

    non_zero_positive?(customers_scores) &&
      score_is_less_than(1_000_000, customers_scores)
  end

  def away_customer_success_are_valid?(away_customer_success, customer_success)
    non_zero_positive?(away_customer_success) &&
      away_customer_success_are_existent_cs?(away_customer_success, customer_success) &&
      away_cs_is_no_less_than_half_available_cs(away_customer_success, customer_success)
  end

  def scores(entity)
    entity.map { |object| object[:score] }
  end

  def no_score_duplicates?(scores)
    scores.uniq.size == scores.size
  end

  def non_zero_positive?(values)
    values.all?(&:positive?)
  end

  def score_is_less_than(value, scores)
    scores.all? { |score| score < value }
  end

  def away_customer_success_are_existent_cs?(away_customer_success, customer_success)
    list_of_customer_success_id = customer_success.map { |cs| cs[:id] }

    away_customer_success & list_of_customer_success_id == away_customer_success
  end

  def away_cs_is_no_less_than_half_available_cs(away_customer_success, customer_success)
    away_customer_success_size = away_customer_success.size
    customer_success_size = customer_success.size

    away_customer_success_size <= (customer_success_size / 2).floor
  end
end
