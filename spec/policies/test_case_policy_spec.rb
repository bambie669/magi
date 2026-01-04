require 'rails_helper'

RSpec.describe TestCasePolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_case) { create(:test_case, test_scope: test_scope) }

  describe "index?" do
    it "permits any logged in user" do
      expect(TestCasePolicy.new(tester, test_case).index?).to be true
    end

    it "denies guest" do
      expect(TestCasePolicy.new(nil, test_case).index?).to be false
    end
  end

  describe "show?" do
    it "permits any logged in user" do
      expect(TestCasePolicy.new(tester, test_case).show?).to be true
    end

    it "denies guest" do
      expect(TestCasePolicy.new(nil, test_case).show?).to be false
    end
  end

  describe "create?" do
    it "permits admin" do
      expect(TestCasePolicy.new(admin, test_case).create?).to be true
    end

    it "permits manager" do
      expect(TestCasePolicy.new(manager, test_case).create?).to be true
    end

    it "permits tester" do
      expect(TestCasePolicy.new(tester, test_case).create?).to be true
    end
  end

  describe "update?" do
    it "permits any logged in user" do
      expect(TestCasePolicy.new(tester, test_case).update?).to be true
    end
  end

  describe "destroy?" do
    it "permits admin" do
      expect(TestCasePolicy.new(admin, test_case).destroy?).to be true
    end

    it "permits manager" do
      expect(TestCasePolicy.new(manager, test_case).destroy?).to be true
    end

    it "denies tester" do
      expect(TestCasePolicy.new(tester, test_case).destroy?).to be false
    end
  end

  describe "Scope" do
    let!(:test_case1) { create(:test_case, test_scope: test_scope, title: "TC1") }
    let!(:test_case2) { create(:test_case, test_scope: test_scope, title: "TC2") }

    it "returns all test cases for admin" do
      scope = TestCasePolicy::Scope.new(admin, TestCase).resolve
      expect(scope).to include(test_case1, test_case2)
    end

    it "returns all test cases for tester" do
      scope = TestCasePolicy::Scope.new(tester, TestCase).resolve
      expect(scope).to include(test_case1, test_case2)
    end
  end
end
