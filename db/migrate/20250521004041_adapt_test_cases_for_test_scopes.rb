class AdaptTestCasesForTestScopes < ActiveRecord::Migration[7.1]
  # Definim modele temporare pentru a lucra cu datele în siguranță în cadrul migrației
  # Acestea reflectă starea tabelelor la momentul rulării migrației.
  class TempTestSuite < ActiveRecord::Base
    self.table_name = :test_suites
    # Nu avem nevoie de asocieri complexe aici, doar de ID-uri
  end

  class TempTestCase < ActiveRecord::Base
    self.table_name = :test_cases
    # belongs_to :temp_test_suite, class_name: 'AdaptTestCasesForTestScopes::TempTestSuite', foreign_key: 'test_suite_id', optional: true
    # belongs_to :temp_test_scope, class_name: 'AdaptTestCasesForTestScopes::TempTestScope', foreign_key: 'test_scope_id', optional: true
  end

  class TempTestScope < ActiveRecord::Base
    self.table_name = :test_scopes
    # belongs_to :temp_test_suite, class_name: 'AdaptTestCasesForTestScopes::TempTestSuite', foreign_key: 'test_suite_id'
  end

  def up
    # 1. Adaugă noua coloană test_scope_id, permițând null inițial
    add_reference :test_cases, :test_scope, foreign_key: true, null: true

    # 2. Migrarea datelor: Populează test_scope_id pentru TestCase-urile existente
    if column_exists?(:test_cases, :test_suite_id)
      say_with_time "Migrating existing TestCases to default TestScopes" do
        TempTestSuite.find_each do |suite|
          # Găsește sau creează un TestScope implicit pentru fiecare TestSuite
          # Acest scope va fi rădăcină (parent_id: nil)
          default_scope_name = "General Cases for Suite #{suite.id}" # Sau un nume mai generic
          
          # Folosim SQL direct pentru a evita validările/callback-urile modelului TestScope
          # și pentru a ne asigura că lucrăm cu coloanele așa cum sunt ele în DB.
          scope_attrs = { name: default_scope_name, test_suite_id: suite.id, created_at: Time.current, updated_at: Time.current }
          
          # Încercăm să găsim un scope existent cu acest nume pentru suită sau îl creăm
          existing_scope = TempTestScope.find_by(name: default_scope_name, test_suite_id: suite.id, parent_id: nil)
          default_scope_id = existing_scope&.id || TempTestScope.insert(scope_attrs, returning: :id).first["id"]

          # Actualizează TestCase-urile care aparțineau acestei suite
          updated_count = TempTestCase.where(test_suite_id: suite.id).update_all(test_scope_id: default_scope_id)
          say "Updated #{updated_count} TestCases for TestSuite ID #{suite.id} to use TestScope ID #{default_scope_id}" if updated_count > 0
        end
      end
    end

    # 3. Acum că toate test_scope_id sunt populate, putem face coloana NOT NULL
    change_column_null :test_cases, :test_scope_id, false

    # 4. Șterge vechea coloană test_suite_id
    if column_exists?(:test_cases, :test_suite_id)
      remove_reference :test_cases, :test_suite, foreign_key: true, index: true
    end
  end

  def down
    # Pentru a face migrația reversibilă:
    # 1. Adaugă înapoi test_suite_id la test_cases (permițând null inițial)
    add_reference :test_cases, :test_suite, foreign_key: true, null: true

    # 2. Migrarea datelor înapoi (opțional, dar bun pentru o reversibilitate completă)
    # Populează test_suite_id bazat pe test_scope.test_suite_id
    # Acest pas presupune că fiecare TestCase are un test_scope_id și fiecare TestScope are un test_suite_id
    if column_exists?(:test_cases, :test_scope_id) && TempTestScope.column_names.include?('test_suite_id')
      say_with_time "Migrating TestCases back to TestSuites from TestScopes" do
        # Iterăm prin fiecare TestCase și îi setăm test_suite_id din TestScope-ul asociat
        # Este mai sigur să facem asta în batch-uri sau cu SQL direct pentru performanță pe volume mari
        TempTestCase.joins("INNER JOIN test_scopes ON test_scopes.id = test_cases.test_scope_id")
                    .update_all("test_suite_id = test_scopes.test_suite_id")
      end
      # Dacă test_suite_id era NOT NULL înainte, ar trebui să verifici și să aplici constrângerea
      # De exemplu, dacă toate au fost populate:
      # change_column_null :test_cases, :test_suite_id, false
    end

    # 3. Șterge coloana test_scope_id
    remove_reference :test_cases, :test_scope, foreign_key: true
  end
end
