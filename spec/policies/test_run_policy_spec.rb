require 'rails_helper'

RSpec.describe TestRunPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:test_run) { create(:test_run, project: project, user: manager) }

  describe "index?" do
    it "permits admin" do
      expect(TestRunPolicy.new(admin, test_run).index?).to be true
    end

    it "permits manager" do
      expect(TestRunPolicy.new(manager, test_run).index?).to be true
    end

    it "permits tester" do
      expect(TestRunPolicy.new(tester, test_run).index?).to be true
    end

    it "denies guest" do
      expect(TestRunPolicy.new(nil, test_run).index?).to be false
    end
  end

  describe "show?" do
    it "permits any logged in user" do
      expect(TestRunPolicy.new(tester, test_run).show?).to be true
    end

    it "denies guest" do
      expect(TestRunPolicy.new(nil, test_run).show?).to be false
    end
  end

  describe "create?" do
    it "permits admin" do
      expect(TestRunPolicy.new(admin, test_run).create?).to be true
    end

    it "permits manager" do
      expect(TestRunPolicy.new(manager, test_run).create?).to be true
    end

    it "permits tester" do
      expect(TestRunPolicy.new(tester, test_run).create?).to be true
    end
  end

  describe "update?" do
    it "permits any logged in user" do
      expect(TestRunPolicy.new(tester, test_run).update?).to be true
    end
  end

  describe "edit?" do
    it "permits admin" do
      expect(TestRunPolicy.new(admin, test_run).edit?).to be true
    end

    it "permits manager who created the run" do
      expect(TestRunPolicy.new(manager, test_run).edit?).to be true
    end

    it "denies manager who didn't create the run" do
      other_manager = create(:user, role: :manager)
      expect(TestRunPolicy.new(other_manager, test_run).edit?).to be false
    end

    it "denies tester" do
      expect(TestRunPolicy.new(tester, test_run).edit?).to be false
    end
  end

  describe "destroy?" do
    it "permits admin" do
      expect(TestRunPolicy.new(admin, test_run).destroy?).to be true
    end

    it "permits manager" do
      expect(TestRunPolicy.new(manager, test_run).destroy?).to be true
    end

    it "denies tester" do
      expect(TestRunPolicy.new(tester, test_run).destroy?).to be false
    end
  end

  describe "Scope" do
    let!(:test_run1) { create(:test_run, project: project, user: admin) }
    let!(:test_run2) { create(:test_run, project: project, user: manager) }

    it "returns all test runs for admin" do
      scope = TestRunPolicy::Scope.new(admin, TestRun).resolve
      expect(scope).to include(test_run1, test_run2)
    end

    it "returns all test runs for tester" do
      scope = TestRunPolicy::Scope.new(tester, TestRun).resolve
      expect(scope).to include(test_run1, test_run2)
    end
  end
end
