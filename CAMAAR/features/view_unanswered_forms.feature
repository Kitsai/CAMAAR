Feature: View unanswered forms

  Scenario: User sees list of unanswered forms
    Given I am logged in
    And I am enrolled in a course
    And there is an unanswered form available for my course
    When I visit the forms page
    Then I should see the unanswered form
    And I should see a link to answer the form

  Scenario: User sees unanswered forms from multiple courses
    Given I am logged in
    And I am enrolled in multiple courses
    And there are unanswered forms available for my courses
    When I visit the forms page
    Then I should see all unanswered forms from my courses

  Scenario: User does not see already answered forms
    Given I am logged in
    And I am enrolled in a course
    And there is an unanswered form available
    And there is a form I have already answered
    When I visit the forms page
    Then I should see the unanswered form
    And I should not see the answered form

  Scenario: User sees message when no forms are available
    Given I am logged in
    And I am enrolled in a course
    And there are no unanswered forms available
    When I visit the forms page
    Then I should see a message indicating no forms are available

  Scenario: User attempts to access form from course they are not enrolled in
    Given I am logged in
    And I am enrolled in a course
    And there is a form for a course I am not enrolled in
    When I attempt to access the form directly
    Then I should see a form unavailable message
    And I should not be able to view the form
