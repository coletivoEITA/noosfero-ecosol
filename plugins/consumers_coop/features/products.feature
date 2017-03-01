Feature: products
  As an collective manager
  I want to see products from the consumers coop

  Background:
    Given "Payments" plugin is enabled
    Given "Orders" plugin is enabled
    Given "Suppliers" plugin is enabled
    Given "OrdersCycle" plugin is enabled
    Given "ConsumersCoop" plugin is enabled

    And the following users
      | login    | name     | email                 |
      | manager  | Manager  | moe@springfield.com   |
    And the following community
      | identifier  | name       | owner   |
      | collective  | Collective | manager |
    And the consumers coop is enabled on "Collective"

    And the following enterprise
      | identifier  | name      | owner   |
      | supplier1   | Supplier1 | manager |
      | supplier2   | Supplier2 | manager |
    And "supplier1" is a supplier of "Collective"
    And "supplier2" is a supplier of "Collective"

    Given I am logged in as "manager"
    And I wait 2 seconds to finish the request
    And I am on collective's homepage

    And I follow "Settings" within ".consumers-coop-plugin_consumers-coop-menu-block"
    And I follow "change"
    And I fill in "profile_data[margin_percentage]" with "10"
    And I press "Confirm"
    And I wait 1 seconds to finish javascript

    And the following product_categories
      | name        |
      | Beer        |
      | Snacks      |
    And the following products
      | owner     | category    | name         | price |
      | supplier2 | snacks      | French fries | 7.00  |
      | supplier1 | beer        | Hainecken    | 3.00  |

  @selenium
  Scenario: change product data in fast edition
    And I follow "Products" within ".consumers-coop-plugin_consumers-coop-menu-block"
    And I wait 2 seconds to finish the request
    And I execute script $('.fast_edition').eq(0).show()
    And I click "product-item:nth-of-type(1) .fast_edition"
    # final price is 8.25
    And I fill in "supplier_price" with "7.5"
    # final price is 8.33
    And I fill in "margin_percentage" with "11"
    And I fill in "name" with "French Fries"
    And I follow "Save"

    And I follow "Products" within ".consumers-coop-plugin_consumers-coop-menu-block"
    And I wait 2 seconds to finish the request
    And I open pry
    And I should see "8.33"
    And I should see "French Fries"

