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
      expect(duplicate.errors[:name]).to include("must be unique within its parent")
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
end
