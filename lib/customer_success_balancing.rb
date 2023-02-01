require_relative 'customer_success_balancing_validator'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    return -1 unless CustomerSuccessBalancingValidator.new.validate(@customer_success, @customers,
                                                                    @away_customer_success)
    return 0 if no_customer_is_available(@customer_success)

    add_customers_by_cs_on_cs(@customer_success, @customers)
    cs_with_most_customers(@customer_success)
  end

  private

  def no_customer_is_available(customer_success)
    delete_away_customer_success(customer_success)

    customer_success.empty?
  end

  def delete_away_customer_success(customer_success)
    customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) }
  end

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
end
