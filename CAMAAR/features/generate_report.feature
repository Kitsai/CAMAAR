Feature: Generate Report as Admin

    Scenario: Admin downloads response reports
        Given I am admin
        And I am on "gerenciamento/resultados" page
        And there are created forms
        When I click on a form
        Then a CSV file containing the form responses should be downloaded