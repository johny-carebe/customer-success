class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    delete_away_customer_success
    sort_cs_by_score
    add_customers_by_cs_on_cs

    cs_with_most_customers
  end

  private

  def cs_with_most_customers
    find_cs_with_most_customers

    most_customers_is_unique ? @cs_with_most_customers[:id] : 0
  end

  def delete_away_customer_success
    @customer_success.delete_if { |cs| @away_customer_success.include?(cs[:id]) }
  end

  def sort_cs_by_score
    @customer_success.sort_by! { |cs| cs[:score] }
  end

  def add_customers_by_cs_on_cs
    previous_cs_score = 0

    @customer_success.each do |cs|
      store_customers_on_cs(cs, previous_cs_score)

      previous_cs_score = cs[:score]
    end
  end

  def store_customers_on_cs(cs, previous_cs_score)
    cs_customers = count_customers_by_cs(cs[:score], previous_cs_score)

    cs.store(:customers, cs_customers)
  end

  def count_customers_by_cs(cs_score, previous_cs_score)
    @customers.count do |customer|
      (customer[:score] <= cs_score) && (customer[:score] > previous_cs_score)
    end
  end

  def find_cs_with_most_customers
    @cs_with_most_customers = @customer_success.max_by { |cs| cs[:customers] }
  end

  def most_customers_is_unique
    @customer_success.count {|cs| cs[:customers] == @cs_with_most_customers[:customers]} == 1
  end
end
