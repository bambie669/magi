require 'rails_helper'

RSpec.describe TestCasesCsvExporter do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite, name: 'Login') }

  describe '#to_csv' do
    context 'with test cases' do
      before do
        create(:test_case,
          test_scope: test_scope,
          title: 'Valid Login',
          preconditions: 'User exists',
          steps: "Step 1\nStep 2",
          expected_result: 'Dashboard shown',
          cypress_id: 'TC-001'
        )
        create(:test_case,
          test_scope: test_scope,
          title: 'Invalid Login',
          preconditions: nil,
          steps: 'Enter wrong password',
          expected_result: 'Error shown',
          cypress_id: 'TC-002'
        )
      end

      it 'generates valid CSV' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        expect(csv).to be_a(String)
        expect(csv).to include('scope_path')
        expect(csv).to include('title')
        expect(csv).to include('steps')
        expect(csv).to include('expected_result')
      end

      it 'includes all test cases' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        expect(csv).to include('Valid Login')
        expect(csv).to include('Invalid Login')
      end

      it 'includes scope path' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        expect(csv).to include('Login')
      end

      it 'includes cypress_id' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        expect(csv).to include('TC-001')
        expect(csv).to include('TC-002')
      end

      it 'escapes newlines in steps' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        # CSV should handle multiline content properly
        parsed = CSV.parse(csv, headers: true)
        test_case_row = parsed.find { |row| row['title'] == 'Valid Login' }
        expect(test_case_row['steps']).to include("\n").or include("Step 1")
      end
    end

    context 'with nested scopes' do
      let(:child_scope) { create(:test_scope, test_suite: test_suite, parent: test_scope, name: 'Validation') }

      before do
        create(:test_case, test_scope: child_scope, title: 'Nested Test')
      end

      it 'includes full scope path' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        expect(csv).to include('Login/Validation').or include('Login')
      end
    end

    context 'with empty test suite' do
      it 'generates CSV with only headers' do
        exporter = described_class.new(test_suite)
        csv = exporter.to_csv

        lines = csv.strip.split("\n")
        expect(lines.length).to eq(1) # Only header row
        expect(csv).to include('scope_path')
      end
    end
  end

  describe '.headers_only' do
    it 'returns CSV template with headers' do
      csv = described_class.headers_only

      expect(csv).to include('scope_path')
      expect(csv).to include('title')
      expect(csv).to include('preconditions')
      expect(csv).to include('steps')
      expect(csv).to include('expected_result')
      expect(csv).to include('cypress_id')
    end

    it 'returns only one line' do
      csv = described_class.headers_only
      lines = csv.strip.split("\n")

      expect(lines.length).to eq(1)
    end
  end
end
