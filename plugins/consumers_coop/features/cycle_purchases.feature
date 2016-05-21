Feature: cycle_purchases
  As an collective consumer
  I want to see purchases from consumers' orders

  Background:
    Given "OrdersCycle" plugin is enabled
    Given "Orders" plugin is enabled
    Given "Suppliers" plugin is enabled
    Given "ConsumersCoop" plugin is enabled
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
    And consumer is member of collective
    And the consumers coop is enabled on "Collective"
    And "supplier" is a supplier of "Collective"
    And I am logged in as "manager"
    And I am on collective's homepage
    And I follow "Orders' Cycles"
    And I follow "New cycle"
    And I fill in "Name" with "Test cycle 1"
    And I fill in "cycle[start_finish_range]" with "Wednesday, May 11, 2016 6:28 PM to Wednesday, May 18, 2020 6:28 PM"
    And I press "Apply"
    And I fill in "cycle[delivery_start_delivery_finish_range]" with "Wednesday, May 19, 2021 4:00 PM to Wednesday, May 19, 2021 6:00 PM"
    And I press "Apply"
    And I press "Create and open orders"
    #And I should see "Close orders"
    And there are no pending jobs
    And I am logged in as "consumer"
    And I am on collective's homepage
    And I press "see orders' cycle"
    And I follow "New order"
    And I add cycle product "French fries"
    And I fill in "item[quantity_consumer_ordered]" with "2"
    And I follow "OK"
    And I press "Confirm order"
    And I confirm the browser dialog
    And there are no pending jobs

  @selenium
  Scenario: view purchases
    Given I am logged in as "manager"
    And I am on collective's homepage
    And I follow "Orders' Cycles"
    And I follow "Test cycle 1"
    And I follow "Purchases"
    And I open the order with "Supplier"
    Then I should see "French fries"
    And  I should not see "Duff"

