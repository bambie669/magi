require 'rails_helper'

RSpec.describe TestSuitePolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, :manager) }
  let(:tester) { create(:user) }
  let(:project) { create(:project, user: admin) }
  let(:test_suite) { create(:test_suite, project: project) }

  describe "#show?" do
    it "permits admin" do
      expect(described_class.new(admin, test_suite).show?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, test_suite).show?).to be true
    end

    it "permits tester" do
      expect(described_class.new(tester, test_suite).show?).to be true
    end
  end

  describe "#create?" do
    it "permits admin" do
      expect(described_class.new(admin, test_suite).create?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, test_suite).create?).to be true
    end

    it "permits tester" do
      expect(described_class.new(tester, test_suite).create?).to be true
    end
  end

  describe "#update?" do
    it "permits admin" do
      expect(described_class.new(admin, test_suite).update?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, test_suite).update?).to be true
    end

    it "permits tester" do
      expect(described_class.new(tester, test_suite).update?).to be true
    end
  end

  describe "#destroy?" do
    it "permits admin" do
      expect(described_class.new(admin, test_suite).destroy?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, test_suite).destroy?).to be true
    end

    it "denies tester" do
      expect(described_class.new(tester, test_suite).destroy?).to be false
    end
  end

  describe "#export_csv?" do
    it "permits any logged in user" do
      expect(described_class.new(admin, test_suite).export_csv?).to be true
      expect(described_class.new(manager, test_suite).export_csv?).to be true
      expect(described_class.new(tester, test_suite).export_csv?).to be true
    end
  end

  describe "#import_csv?" do
    it "permits admin" do
      expect(described_class.new(admin, test_suite).import_csv?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, test_suite).import_csv?).to be true
    end

    it "permits tester" do
      expect(described_class.new(tester, test_suite).import_csv?).to be true
    end
  end

  describe "Scope" do
    let!(:test_suite1) { create(:test_suite, project: project) }
    let!(:test_suite2) { create(:test_suite, project: project) }

    it "returns all test suites for admin" do
      resolved_scope = described_class::Scope.new(admin, TestSuite.all).resolve
      expect(resolved_scope).to include(test_suite1, test_suite2)
    end

    it "returns all test suites for manager" do
      resolved_scope = described_class::Scope.new(manager, TestSuite.all).resolve
      expect(resolved_scope).to include(test_suite1, test_suite2)
    end

    it "returns all test suites for tester" do
      resolved_scope = described_class::Scope.new(tester, TestSuite.all).resolve
      expect(resolved_scope).to include(test_suite1, test_suite2)
    end

    it "returns no test suites for nil user" do
      resolved_scope = described_class::Scope.new(nil, TestSuite.all).resolve
      expect(resolved_scope).to be_empty
    end
  end
end
