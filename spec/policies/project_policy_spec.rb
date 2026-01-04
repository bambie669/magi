require 'rails_helper'

RSpec.describe ProjectPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, :manager) }
  let(:creator_manager) { create(:user, :manager) }
  let(:tester) { create(:user) }
  let(:project) { create(:project, user: creator_manager) }

  describe "#index? and #show?" do
    it "permits admin" do
      expect(described_class.new(admin, project).index?).to be true
      expect(described_class.new(admin, project).show?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, project).index?).to be true
      expect(described_class.new(manager, project).show?).to be true
    end

    it "permits tester" do
      expect(described_class.new(tester, project).index?).to be true
      expect(described_class.new(tester, project).show?).to be true
    end
  end

  describe "#create? and #new?" do
    it "permits admin" do
      expect(described_class.new(admin, project).create?).to be true
    end

    it "permits manager" do
      expect(described_class.new(manager, project).create?).to be true
    end

    it "denies tester" do
      expect(described_class.new(tester, project).create?).to be false
    end
  end

  describe "#update? and #edit?" do
    it "permits admin" do
      expect(described_class.new(admin, project).update?).to be true
    end

    it "permits creator manager" do
      expect(described_class.new(creator_manager, project).update?).to be true
    end

    it "denies other manager" do
      expect(described_class.new(manager, project).update?).to be false
    end

    it "denies tester" do
      expect(described_class.new(tester, project).update?).to be false
    end
  end

  describe "#destroy?" do
    it "permits admin" do
      expect(described_class.new(admin, project).destroy?).to be true
    end

    it "denies manager" do
      expect(described_class.new(manager, project).destroy?).to be false
      expect(described_class.new(creator_manager, project).destroy?).to be false
    end

    it "denies tester" do
      expect(described_class.new(tester, project).destroy?).to be false
    end
  end

  describe "Scope" do
    let!(:project1) { create(:project, user: manager) }
    let!(:project2) { create(:project, user: admin) }

    it "returns all projects for admin" do
      resolved_scope = described_class::Scope.new(admin, Project.all).resolve
      expect(resolved_scope).to include(project1, project2)
    end

    it "returns all projects for manager" do
      resolved_scope = described_class::Scope.new(manager, Project.all).resolve
      expect(resolved_scope).to include(project1, project2)
    end

    it "returns all projects for tester" do
      resolved_scope = described_class::Scope.new(tester, Project.all).resolve
      expect(resolved_scope).to include(project1, project2)
    end

    it "returns no projects for nil user" do
      resolved_scope = described_class::Scope.new(nil, Project.all).resolve
      expect(resolved_scope).to be_empty
    end
  end
end