class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    return -1 unless inputs_are_valid(@customer_success, @customers, @away_customer_success)
    return 0 if no_customer_is_available(@customer_success)

    add_customers_by_cs_on_cs(@customer_success, @customers)
    cs_with_most_customers(@customer_success)
  end

  private

  def add_customers_by_cs_on_cs(customer_success, customers)
    sort_customer_success_by_score(customer_success)

    cs_customers = search_cs_customers(customers, customer_success, Hash.new(0))

    update_cs_costumers_on_cs(customer_success, cs_customers)
  end

  def sort_customer_success_by_score(customer_success)
    customer_success.sort_by! { |cs| cs[:score] }
  end

  def search_cs_customers(customers, customer_success, cs_customers)
    customers.each do |customer|
      customers_by_cs = search_customer_success_by_customer(customer_success, customer)
      cs_customers[customers_by_cs[:id]] += 1 unless customers_by_cs.nil?
    end

    cs_customers
  end

  def search_customer_success_by_customer(customer_success, customer)
    customer_success.bsearch { |cs| cs[:score] >= customer[:score] }
  end

  def update_cs_costumers_on_cs(customer_success, store_cs_customers)
    customer_success.each { |cs| cs[:customers] = store_cs_customers[cs[:id]] }
  end

  def cs_with_most_customers(customer_success)
    cs_with_most_customers = find_cs_with_most_customers(customer_success)
    cs_with_most_customers_is_unique = most_customers_is_unique(customer_success, cs_with_most_customers)

    cs_with_most_customers_is_unique ? cs_with_most_customers[:id] : 0
  end

  def find_cs_with_most_customers(customer_success)
    customer_success.max_by { |cs| cs[:customers] }
  end

  def most_customers_is_unique(customer_success, cs_with_most_customers)
    customer_success.count { |cs| cs[:customers] == cs_with_most_customers[:customers] } == 1
  end

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

  def no_customer_is_available(customer_success)
    delete_away_customer_success(customer_success)

    customer_success.empty?
  end

  def delete_away_customer_success(customer_success)
    customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) }
  end
end
