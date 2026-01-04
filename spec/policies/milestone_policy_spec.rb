require 'rails_helper'

RSpec.describe MilestonePolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:manager) { create(:user, role: :manager) }
  let(:tester) { create(:user, role: :tester) }
  let(:project) { create(:project, user: admin) }
  let(:milestone) { create(:milestone, project: project) }

  describe "index?" do
    it "permits any logged in user" do
      expect(MilestonePolicy.new(tester, milestone).index?).to be true
    end

    it "denies guest" do
      expect(MilestonePolicy.new(nil, milestone).index?).to be false
    end
  end

  describe "show?" do
    it "permits any logged in user" do
      expect(MilestonePolicy.new(tester, milestone).show?).to be true
    end

    it "denies guest" do
      expect(MilestonePolicy.new(nil, milestone).show?).to be false
    end
  end

  describe "create?" do
    it "permits admin" do
      expect(MilestonePolicy.new(admin, milestone).create?).to be true
    end

    it "permits manager" do
      expect(MilestonePolicy.new(manager, milestone).create?).to be true
    end

    it "denies tester" do
      expect(MilestonePolicy.new(tester, milestone).create?).to be false
    end
  end

  describe "update?" do
    it "permits admin" do
      expect(MilestonePolicy.new(admin, milestone).update?).to be true
    end

    it "permits manager" do
      expect(MilestonePolicy.new(manager, milestone).update?).to be true
    end

    it "denies tester" do
      expect(MilestonePolicy.new(tester, milestone).update?).to be false
    end
  end

  describe "destroy?" do
    it "permits admin" do
      expect(MilestonePolicy.new(admin, milestone).destroy?).to be true
    end

    it "permits manager" do
      expect(MilestonePolicy.new(manager, milestone).destroy?).to be true
    end

    it "denies tester" do
      expect(MilestonePolicy.new(tester, milestone).destroy?).to be false
    end
  end

  describe "Scope" do
    let!(:milestone1) { create(:milestone, project: project, name: "M1") }
    let!(:milestone2) { create(:milestone, project: project, name: "M2") }

    it "returns all milestones for admin" do
      scope = MilestonePolicy::Scope.new(admin, Milestone).resolve
      expect(scope).to include(milestone1, milestone2)
    end

    it "returns all milestones for tester" do
      scope = MilestonePolicy::Scope.new(tester, Milestone).resolve
      expect(scope).to include(milestone1, milestone2)
    end

    it "returns none for guest" do
      scope = MilestonePolicy::Scope.new(nil, Milestone).resolve
      expect(scope).to be_empty
    end
  end
end
