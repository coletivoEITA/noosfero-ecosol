Feature: cycle_purchases
  As an collective consumer
  I want to see purchases from consumers' orders

  Background:
    Given "OrdersCycle" plugin is enabled
    And feature "products_for_enterprises" is enabled on environment
    And the following product_categories
      | name        |
      | Beer        |
      | Snacks      |
    And the following users
      | login    | name     | email                 |
      | manager  | Manager  | moe@springfield.com   |
      | consumer | Consumer | homer@springfield.com |
    And the following enterprise
      | identifier  | name     | owner   |
      | supplier    | Supplier | manager |
    And the following products
      | owner    | category    | name         | price |
      | supplier | beer        | Duff         | 3.00  |
      | supplier | snacks      | French fries | 7.00  |
    And the following community
      | identifier  | name       | owner   |
      | collective  | Collective | manager |
    And "Manager" is admin of "Collective"
    And the consumers coop is enabled on "Collective"
    And "supplier" is a supplier of "Collective"
    And I am logged in as "manager"
    And I am on collective's home
    And I follow "Orders' cycles"
    And I follow "New cycle"
    And I fill "Name" with 'Test cycle 1'
    And I fill "cycle[start_finish_range]"                   with 'Wednesday, May 11, 2016 6:28 PM to Wednesday, May 18, 2016 6:28 PM'
    And I fill "cycle[delivery_start_delivery_finish_range]" with 'Wednesday, May 19, 2016 4:00 PM to Wednesday, May 19, 2016 6:00 PM'
    And I follow "Create and open orders"
    And delayed jobs are processed
    And I am logged in as "consumer"
    And I am on collective's home
    And I follow "See orders' cycle"
    And I follow "New order"
    And I click "French fries"
    And I fill "item[quantity_consumer_ordered]" with '2'
    And I follow "OK"
    And I follow "Confirm order"
    And delayed jobs are processed

  @selenium
  Scenario: view purchases
    Given I am logged in as "manager"
    And I am on collective's home
    And I follow "Orders' cycles"
    And I follow "Test cycle 1"
    And I follow "Purchases"
    And I click "supplier"
    Then I should see "French fried"
    And  I should not see "Duff"

