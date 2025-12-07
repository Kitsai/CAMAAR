Feature: Export class performance as CSV

  Scenario: Admin exports CSV for their classes
    Given I am an admin
    And I have created forms for some courses
    And there are student answers for these courses
    When I visit the results page
    Then I should see my courses listed
    When I click to export CSV for a course
    Then I should download a CSV file with the class performance data

  Scenario: Admin attempts to export CSV for a class they don't manage
    Given I am an admin
    And I have created forms for some courses
    When I try to access the CSV export for a course I don't manage
    Then I should see an access denied message
    And no CSV file should be downloaded