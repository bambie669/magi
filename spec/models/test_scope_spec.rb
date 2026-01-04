require 'rails_helper'

RSpec.describe TestScope, type: :model do
  describe "associations" do
    it { should belong_to(:test_suite) }
    it { should belong_to(:parent).class_name('TestScope').optional }
    it { should have_many(:children).class_name('TestScope').with_foreign_key('parent_id').dependent(:destroy) }
    it { should have_many(:test_cases).with_foreign_key('test_scope_id').dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:test_scope) }

    it { should validate_presence_of(:name) }

    it "validates uniqueness of name within parent and test_suite" do
      test_suite = create(:test_suite)
      create(:test_scope, name: "Scope A", test_suite: test_suite, parent: nil)

      duplicate = build(:test_scope, name: "Scope A", test_suite: test_suite, parent: nil)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("Folder name must be unique within its parent folder or at the root of the suite.")
    end

    it "allows same name in different parents" do
      test_suite = create(:test_suite)
      parent1 = create(:test_scope, name: "Parent 1", test_suite: test_suite)
      parent2 = create(:test_scope, name: "Parent 2", test_suite: test_suite)

      create(:test_scope, name: "Child", test_suite: test_suite, parent: parent1)
      child2 = build(:test_scope, name: "Child", test_suite: test_suite, parent: parent2)

      expect(child2).to be_valid
    end
  end

  describe "#all_test_cases_recursive" do
    let(:test_suite) { create(:test_suite) }
    let(:parent_scope) { create(:test_scope, test_suite: test_suite) }
    let(:child_scope) { create(:test_scope, test_suite: test_suite, parent: parent_scope) }
    let(:grandchild_scope) { create(:test_scope, test_suite: test_suite, parent: child_scope) }

    before do
      @parent_case = create(:test_case, test_scope: parent_scope, title: "Parent Case", steps: "Step 1", expected_result: "Result 1")
      @child_case = create(:test_case, test_scope: child_scope, title: "Child Case", steps: "Step 2", expected_result: "Result 2")
      @grandchild_case = create(:test_case, test_scope: grandchild_scope, title: "Grandchild Case", steps: "Step 3", expected_result: "Result 3")
    end

    it "returns test cases from current scope and all descendants" do
      result = parent_scope.all_test_cases_recursive

      expect(result).to include(@parent_case)
      expect(result).to include(@child_case)
      expect(result).to include(@grandchild_case)
      expect(result.length).to eq(3)
    end

    it "returns only current scope test cases when no children" do
      result = grandchild_scope.all_test_cases_recursive

      expect(result).to include(@grandchild_case)
      expect(result.length).to eq(1)
    end

    it "returns empty array when no test cases exist" do
      empty_scope = create(:test_scope, test_suite: test_suite)
      expect(empty_scope.all_test_cases_recursive).to be_empty
    end
  end

  describe "#all_descendant_scopes" do
    let(:test_suite) { create(:test_suite) }
    let(:parent_scope) { create(:test_scope, test_suite: test_suite) }
    let(:child_scope1) { create(:test_scope, test_suite: test_suite, parent: parent_scope) }
    let(:child_scope2) { create(:test_scope, test_suite: test_suite, parent: parent_scope) }
    let(:grandchild_scope) { create(:test_scope, test_suite: test_suite, parent: child_scope1) }

    before do
      # Force creation of all scopes
      grandchild_scope
      child_scope2
    end

    it "returns all descendant scopes" do
      result = parent_scope.all_descendant_scopes

      expect(result).to include(child_scope1)
      expect(result).to include(child_scope2)
      expect(result).to include(grandchild_scope)
      expect(result.length).to eq(3)
    end

    it "returns empty array for leaf scope" do
      expect(grandchild_scope.all_descendant_scopes).to be_empty
    end
  end
end
