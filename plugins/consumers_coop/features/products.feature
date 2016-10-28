Feature: products
  As an collective manager
  I want to see products from the consumers coop

  Background:
    Given "Payments" plugin is enabled
    Given "Orders" plugin is enabled
    Given "Suppliers" plugin is enabled
    Given "OrdersCycle" plugin is enabled
    Given "ConsumersCoop" plugin is enabled

    And the following product_categories
      | name        |
      | Beer        |
      | Snacks      |
    And the following users
      | login    | name     | email                 |
      | manager  | Manager  | moe@springfield.com   |
    And the following enterprise
      | identifier  | name     | owner   |
      | supplier1   | Supplier | manager |
      | supplier2   | Supplier | manager |
    And the following products
      | owner     | category    | name         | price |
      | supplier1 | beer        | Hainecken    | 3.00  |
      | supplier2 | snacks      | French fries | 7.00  |
    And the following community
      | identifier  | name       | owner   |
      | collective  | Collective | manager |

    And "Manager" is admin of "Collective"
    And the consumers coop is enabled on "Collective"
    And "supplier1" is a supplier of "Collective"
    And "supplier2" is a supplier of "Collective"

  @selenium
  Scenario: view purchases
    Given I am logged in as "manager"
    And I wait 2 seconds to finish the request
    And I am on collective's homepage
    And I follow "Products" within ".consumers-coop-plugin_consumers-coop-menu-block"
    And I move the cursor over "product-item .name span:contains('French fries')"
    And I open pry
    And I click "fast edition"

