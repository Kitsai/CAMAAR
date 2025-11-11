Feature: User Login

  Scenario: User logs in successfully
    Given I am on login page
    When I enter valid credentials
    Then I should see the homepage

  Scenario: User logs in unsuccessfully
    Given I am on login page
    When I enter invalid credentials
    Then I should see an error message
