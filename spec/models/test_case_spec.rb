require 'rails_helper'

RSpec.describe TestCase, type: :model do
  describe "associations" do
    it { should belong_to(:test_scope) }
    it { should have_many(:test_run_cases).dependent(:destroy) }
    it { should have_one(:test_suite).through(:test_scope) }
    it { should have_one(:project).through(:test_suite) }
  end

  describe "validations" do
    subject { create(:test_case) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:steps) }
    it { should validate_presence_of(:expected_result) }
    it { should validate_presence_of(:test_scope_id) }

    describe "cypress_id uniqueness" do
      let(:test_suite) { create(:test_suite) }
      let(:test_scope) { create(:test_scope, test_suite: test_suite) }
      let(:other_test_scope) { create(:test_scope, test_suite: test_suite) }

      it "allows blank cypress_id" do
        test_case = build(:test_case, test_scope: test_scope, cypress_id: nil)
        expect(test_case).to be_valid
      end

      it "allows unique cypress_id within same test suite" do
        create(:test_case, test_scope: test_scope, cypress_id: "TC-001")
        test_case = build(:test_case, test_scope: test_scope, cypress_id: "TC-002")
        expect(test_case).to be_valid
      end

      it "rejects duplicate cypress_id within same test suite" do
        create(:test_case, test_scope: test_scope, cypress_id: "TC-001")
        test_case = build(:test_case, test_scope: other_test_scope, cypress_id: "TC-001")
        expect(test_case).not_to be_valid
        expect(test_case.errors[:cypress_id]).to include("has already been taken in this test suite")
      end

      it "allows same cypress_id in different test suites" do
        other_suite = create(:test_suite)
        other_scope = create(:test_scope, test_suite: other_suite)
        create(:test_case, test_scope: test_scope, cypress_id: "TC-001")
        test_case = build(:test_case, test_scope: other_scope, cypress_id: "TC-001")
        expect(test_case).to be_valid
      end

      it "allows multiple blank cypress_ids" do
        create(:test_case, test_scope: test_scope, cypress_id: nil)
        create(:test_case, test_scope: test_scope, cypress_id: "")
        test_case = build(:test_case, test_scope: test_scope, cypress_id: nil)
        expect(test_case).to be_valid
      end
    end
  end

  describe "through associations" do
    it "accesses test_suite through test_scope" do
      test_suite = create(:test_suite)
      test_scope = create(:test_scope, test_suite: test_suite)
      test_case = create(:test_case, test_scope: test_scope)

      expect(test_case.test_suite).to eq(test_suite)
    end

    it "accesses project through test_suite" do
      project = create(:project)
      test_suite = create(:test_suite, project: project)
      test_scope = create(:test_scope, test_suite: test_suite)
      test_case = create(:test_case, test_scope: test_scope)

      expect(test_case.project).to eq(project)
    end
  end
end
