require 'rails_helper'

RSpec.describe TestSuite, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "associations" do
    it { should belong_to(:project) }
    it { should have_many(:test_scopes).dependent(:destroy) }
    it { should have_many(:root_test_scopes).class_name('TestScope') }
  end

  describe "factory" do
    it "creates a valid test suite" do
      test_suite = build(:test_suite)
      expect(test_suite).to be_valid
    end
  end

  describe "#test_cases association" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:test_suite) { create(:test_suite, project: project) }

    context "with test cases in root scope" do
      let(:test_scope) { create(:test_scope, test_suite: test_suite) }
      let!(:test_case1) { create(:test_case, test_scope: test_scope, title: "Test 1") }
      let!(:test_case2) { create(:test_case, test_scope: test_scope, title: "Test 2") }

      it "returns all test cases" do
        expect(test_suite.test_cases).to contain_exactly(test_case1, test_case2)
      end
    end

    context "with nested scopes" do
      let(:parent_scope) { create(:test_scope, test_suite: test_suite, name: "Parent") }
      let(:child_scope) { create(:test_scope, test_suite: test_suite, parent: parent_scope, name: "Child") }
      let!(:parent_test) { create(:test_case, test_scope: parent_scope) }
      let!(:child_test) { create(:test_case, test_scope: child_scope) }

      it "returns test cases from all levels" do
        expect(test_suite.test_cases).to contain_exactly(parent_test, child_test)
      end
    end

    context "with no test cases" do
      it "returns empty relation" do
        expect(test_suite.test_cases.to_a).to eq([])
      end
    end
  end
end
