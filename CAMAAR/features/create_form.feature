Feature: Create Form

  Scenario: Form created successfully
    Given I am an admin
    And there is at least one template
    And there is at least one class
    And I am on the gerenciamento page
    When I open the send form modal
    And I select a template
    And I select at least one class
    And I click the send form button
    Then I should see a success message
    And the new form should be assigned to the selected classes
    And the new form should be available on the gerenciamento - results page

  Scenario: Tried to create form without selecting template
    Given I am an admin
    And there is at least one class
    And I am on the gerenciamento page
    When I open the send form modal
    And I do not select a template
    And I select at least one class
    And I click the send form button
    Then I should see an error message that I need to select a template

  Scenario: Tried to create form without selecting classes
    Given I am an admin
    And there is at least one template
    And I am on the gerenciamento page
    When I open the send form modal
    And I select a template
    And I do not select any class
    And I click the send form button
    Then I should see an error message that I need to select at least one class