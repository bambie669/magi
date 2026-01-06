require 'rails_helper'

RSpec.describe TestCasesCsvImporter do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:test_suite) { create(:test_suite, project: project) }

  def create_csv_file(content)
    file = Tempfile.new(['test_cases', '.csv'])
    file.write(content)
    file.rewind
    file
  end

  describe '#import' do
    context 'with valid standard format CSV' do
      let(:csv_content) do
        <<~CSV
          scope_path,title,preconditions,steps,expected_result,cypress_id
          Login,Valid login test,User exists,1. Enter email\\n2. Enter password,User sees dashboard,TC-001
          Login,Invalid login test,,1. Enter wrong email,Error message shown,TC-002
        CSV
      end

      it 'imports test cases successfully' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:success]).to be true
        expect(result[:imported]).to eq(2)
        expect(result[:errors]).to be_empty
      end

      it 'creates test scopes automatically' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)

        expect { importer.import }.to change(TestScope, :count).by(1)
        expect(test_suite.test_scopes.find_by(name: 'Login')).to be_present
      end

      it 'creates test cases with correct attributes' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        importer.import

        test_case = TestCase.find_by(cypress_id: 'TC-001')
        expect(test_case.title).to eq('Valid login test')
        expect(test_case.preconditions).to eq('User exists')
        expect(test_case.steps).to include('Enter email')
        expect(test_case.expected_result).to eq('User sees dashboard')
      end

      it 'converts \\n to actual newlines in steps and expected_result' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        importer.import

        test_case = TestCase.find_by(cypress_id: 'TC-001')
        expect(test_case.steps).to include("\n")
      end
    end

    context 'with nested scope paths' do
      let(:csv_content) do
        <<~CSV
          scope_path,title,steps,expected_result
          Auth/Login/Validation,Email validation,Enter invalid email,Error shown
        CSV
      end

      it 'creates nested scopes' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        importer.import

        auth_scope = test_suite.test_scopes.find_by(name: 'Auth')
        login_scope = test_suite.test_scopes.find_by(name: 'Login')
        validation_scope = test_suite.test_scopes.find_by(name: 'Validation')

        expect(auth_scope).to be_present
        expect(login_scope.parent).to eq(auth_scope)
        expect(validation_scope.parent).to eq(login_scope)
      end
    end

    context 'with duplicate test cases' do
      let(:csv_content) do
        <<~CSV
          scope_path,title,steps,expected_result,cypress_id
          Login,Test 1,Step 1,Result 1,TC-001
          Login,Test 1,Step 2,Result 2,TC-001
        CSV
      end

      it 'skips duplicates by cypress_id' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        expect(result[:duplicates]).to eq(1)
      end
    end

    context 'with existing test cases' do
      before do
        scope = create(:test_scope, test_suite: test_suite, name: 'Login')
        create(:test_case, test_scope: scope, cypress_id: 'TC-001', title: 'Existing test')
      end

      let(:csv_content) do
        <<~CSV
          scope_path,title,steps,expected_result,cypress_id
          Login,New test,Step 1,Result 1,TC-001
        CSV
      end

      it 'skips test cases with existing cypress_id' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:duplicates]).to eq(1)
        expect(result[:imported]).to eq(0)
      end
    end

    context 'with missing required fields' do
      let(:csv_content) do
        <<~CSV
          scope_path,title,steps,expected_result
          Login,,Step 1,Result 1
        CSV
      end

      it 'skips rows without title' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(0)
        expect(result[:skipped]).to be >= 1
      end
    end

    context 'with section headers in CSV' do
      let(:csv_content) do
        <<~CSV
          scope_path,title,steps,expected_result
          Authentication
          ,Login test,Step 1,Result 1
        CSV
      end

      it 'uses section header as scope path' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        test_case = TestCase.find_by(title: 'Login test')
        expect(test_case.test_scope.name).to eq('Authentication')
      end
    end

    context 'with TestRail format CSV' do
      let(:csv_content) do
        <<~CSV
          Test Case Number,Test Title,Prerequisites,Test Steps,Expected Results
          TC-001,Login Test,User exists,Enter credentials,Dashboard shown
        CSV
      end

      it 'maps TestRail columns correctly' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        test_case = TestCase.find_by(cypress_id: 'TC-001')
        expect(test_case.title).to eq('Login Test')
        expect(test_case.preconditions).to eq('User exists')
      end
    end

    context 'with empty CSV' do
      let(:csv_content) { "scope_path,title,steps,expected_result\n" }

      it 'returns success with zero imports' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:success]).to be true
        expect(result[:imported]).to eq(0)
      end
    end

    context 'with malformed CSV' do
      let(:csv_content) { "this is not,valid csv content\"\"\"" }

      it 'handles CSV parsing errors gracefully' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        # Should not raise, but may have errors or low import count
        expect(result).to have_key(:imported)
      end
    end

    context 'with no scope_path column' do
      let(:csv_content) do
        <<~CSV
          title,steps,expected_result
          Test 1,Step 1,Result 1
        CSV
      end

      it 'uses default scope' do
        file = create_csv_file(csv_content)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        test_case = TestCase.find_by(title: 'Test 1')
        expect(test_case.test_scope.name).to eq('Imported')
      end
    end
  end

  describe 'result accessors' do
    it 'provides error count' do
      file = create_csv_file("title,steps,expected_result\n")
      importer = described_class.new(test_suite, file)
      importer.import

      expect(importer.errors).to be_an(Array)
      expect(importer.imported_count).to be_a(Integer)
      expect(importer.duplicate_count).to be_a(Integer)
      expect(importer.skipped_count).to be_a(Integer)
    end
  end
end
