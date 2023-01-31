class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    delete_away_customer_success(@customer_success)

    return 0 if no_customer_is_available(@customer_success)

    sort_by_score(@customer_success)
    sort_by_score(@customers)
    add_customers_by_cs_on_cs(@customer_success, @customers)

    cs_with_most_customers(@customer_success)
  end

  private

  def cs_with_most_customers(customer_success)
    cs_with_most_customers = find_cs_with_most_customers(customer_success)

    if most_customers_is_unique(customer_success, cs_with_most_customers)
      cs_with_most_customers[:id]
    else
      0
    end
  end

  def delete_away_customer_success(customer_success)
    customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) }
  end

  def no_customer_is_available(customer_success)
    customer_success.empty?
  end

  def sort_by_score(entities)
    entities.sort_by! { |entity| entity[:score] }
  end

  def add_customers_by_cs_on_cs(customer_success, customers)
    previous_cs_score = 0

    customer_success.each do |cs|
      store_customers_on_cs(customers, cs, previous_cs_score)

      previous_cs_score = cs[:score]
    end
  end

  def store_customers_on_cs(customers, cs, previous_cs_score)
    cs_customers = count_customers_by_cs(customers, cs[:score], previous_cs_score)

    cs.store(:customers, cs_customers)
  end

  def count_customers_by_cs(customers, cs_score, previous_cs_score)
    customers.count do |customer|
      (customer[:score] <= cs_score) && (customer[:score] > previous_cs_score)
    end
  end

  def find_cs_with_most_customers(customer_success)
    customer_success.max_by { |cs| cs[:customers] }
  end

  def most_customers_is_unique(customer_success, cs_with_most_customers)
    customer_success.count { |cs| cs[:customers] == cs_with_most_customers[:customers] } == 1
  end
end
