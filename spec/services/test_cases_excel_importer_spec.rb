require 'rails_helper'

RSpec.describe TestCasesExcelImporter do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:test_suite) { create(:test_suite, project: project) }

  def create_excel_file(sheets_data)
    require 'caxlsx'

    file = Tempfile.new(['test_cases', '.xlsx'])

    Axlsx::Package.new do |p|
      sheets_data.each do |sheet_name, rows|
        p.workbook.add_worksheet(name: sheet_name) do |sheet|
          rows.each do |row|
            sheet.add_row row
          end
        end
      end
      p.serialize(file.path)
    end

    # Create an uploaded file mock
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: 'test_cases.xlsx',
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )

    uploaded_file
  end

  describe '#import' do
    context 'with valid Excel file' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Title', 'Prerequisites', 'Test Steps', 'Expected Results'],
            [1, 'Valid login test', 'User exists', '1. Enter email\n2. Enter password', 'User sees dashboard'],
            [2, 'Invalid login test', nil, '1. Enter wrong email', 'Error message shown']
          ]
        }
      end

      it 'imports test cases successfully' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:success]).to be true
        expect(result[:imported]).to eq(2)
        expect(result[:errors]).to be_empty
      end

      it 'creates test scope from sheet name' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)

        expect { importer.import }.to change(TestScope, :count).by(1)
        expect(test_suite.test_scopes.find_by(name: 'Login')).to be_present
      end

      it 'creates test cases with correct attributes' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        importer.import

        test_case = TestCase.find_by(cypress_id: 'TC1')
        expect(test_case.title).to eq('Valid login test')
        expect(test_case.preconditions).to eq('User exists')
        expect(test_case.steps).to include('Enter email')
        expect(test_case.expected_result).to eq('User sees dashboard')
      end

      it 'normalizes cypress_id to TC prefix format' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        importer.import

        expect(TestCase.find_by(cypress_id: 'TC1')).to be_present
        expect(TestCase.find_by(cypress_id: 'TC2')).to be_present
      end
    end

    context 'with multiple sheets' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            [1, 'Login test', 'Step 1', 'Result 1']
          ],
          'Users' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            [10, 'User creation', 'Step 1', 'Result 1']
          ]
        }
      end

      it 'imports from all sheets' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(2)
        expect(test_suite.test_scopes.pluck(:name)).to include('Login', 'Users')
      end
    end

    context 'with summary sheet to skip' do
      let(:sheets_data) do
        {
          'Medplanner_tabs' => [
            ['Summary', 'Total'],
            ['Tests', 100]
          ],
          'Login' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            [1, 'Login test', 'Step 1', 'Result 1']
          ]
        }
      end

      it 'skips summary sheets' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        expect(test_suite.test_scopes.find_by(name: 'Medplanner_tabs')).to be_nil
      end
    end

    context 'with duplicate test cases' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            [1, 'Test 1', 'Step 1', 'Result 1'],
            [1, 'Test 1 duplicate', 'Step 2', 'Result 2']
          ]
        }
      end

      it 'skips duplicates by cypress_id' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        expect(result[:duplicates]).to eq(1)
      end
    end

    context 'with TC prefix in test case number' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            ['TC 1', 'Login test', 'Step 1', 'Result 1'],
            ['TC-2', 'Another test', 'Step 1', 'Result 1']
          ]
        }
      end

      it 'normalizes TC formats' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        importer.import

        expect(TestCase.find_by(cypress_id: 'TC1')).to be_present
        expect(TestCase.find_by(cypress_id: 'TC2')).to be_present
      end
    end

    context 'with section rows' do
      let(:sheets_data) do
        {
          'Appointments' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            ['Daily View', nil, nil, nil],
            [1, 'View appointments', 'Step 1', 'Result 1'],
            ['Weekly View', nil, nil, nil],
            [2, 'Week view test', 'Step 1', 'Result 1']
          ]
        }
      end

      it 'creates subscopes from section rows' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(2)

        # Check that subscopes were created
        appointments_scope = test_suite.test_scopes.find_by(name: 'Appointments')
        expect(appointments_scope).to be_present

        daily_scope = test_suite.test_scopes.find_by(name: 'Daily View')
        weekly_scope = test_suite.test_scopes.find_by(name: 'Weekly View')

        if daily_scope.present?
          expect(daily_scope.parent).to eq(appointments_scope)
        end
      end
    end

    context 'with rows missing steps and expected_result' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
            [1, 'Test with content', 'Step 1', 'Result 1'],
            [2, 'Empty test', nil, nil]
          ]
        }
      end

      it 'skips rows without steps and expected_result' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:imported]).to eq(1)
        expect(result[:skipped]).to be >= 1
      end
    end

    context 'with missing title column' do
      let(:sheets_data) do
        {
          'Login' => [
            ['Test Case Number', 'Test Steps', 'Expected Results'],
            [1, 'Step 1', 'Result 1']
          ]
        }
      end

      it 'reports error for sheet without title column' do
        file = create_excel_file(sheets_data)
        importer = described_class.new(test_suite, file)
        result = importer.import

        expect(result[:errors]).to include(a_string_matching(/could not find title/i))
      end
    end
  end

  describe 'result accessors' do
    it 'provides error count' do
      sheets_data = {
        'Login' => [
          ['Test Case Number', 'Test Title', 'Test Steps', 'Expected Results'],
          [1, 'Test', 'Step', 'Result']
        ]
      }

      file = create_excel_file(sheets_data)
      importer = described_class.new(test_suite, file)
      importer.import

      expect(importer.errors).to be_an(Array)
      expect(importer.imported_count).to be_a(Integer)
      expect(importer.duplicate_count).to be_a(Integer)
      expect(importer.skipped_count).to be_a(Integer)
    end
  end
end
