Feature: View Forms

    Scenario: View created forms sucessfully
        Given I am an admin
        And I am on the "gerenciamento" page
        And there are created forms
        When I click in "Resultados" button
        Then I should be redirected to "gerenciamento/resultados"
        And I should view the page with created forms

    Scenario: Tried to view forms without created forms
        Given I am an admin
        And I am on the "gerenciamento" page
        And there are no created forms
        When I click in "Resultados" button
        Then I should be redirected to "gerenciamento/resultados"
        And I should see a message indicating no forms exist
