require 'rails_helper'

RSpec.describe ProjectPolicy, type: :policy do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:creator_manager) { FactoryBot.create(:user, :manager) } # Manager care creează proiectul
  let(:tester) { FactoryBot.create(:user, :tester) }
  let(:other_user) { FactoryBot.create(:user) } # Alt tester
  let(:project) { FactoryBot.create(:project, user: creator_manager) } # Proiect creat de creator_manager

  subject { described_class }

  permissions :index?, :show? do
    it "grants access if user is present (admin, manager, tester)" do
      expect(subject).to permit(admin, Project.new) # Folosim Project.new pt acțiuni non-specifice recordului
      expect(subject).to permit(manager, Project.new)
      expect(subject).to permit(tester, Project.new)
    end

     it "denies access if user is nil" do
       expect(subject).not_to permit(nil, Project.new)
     end
  end

  permissions :create?, :new? do
    it "grants access if user is admin" do
      expect(subject).to permit(admin, Project.new)
    end

    it "grants access if user is manager" do
      expect(subject).to permit(manager, Project.new)
    end

    it "denies access if user is tester" do
      expect(subject).not_to permit(tester, Project.new)
    end
  end

  permissions :update?, :edit? do
    it "grants access if user is admin" do
      expect(subject).to permit(admin, project)
    end

    it "grants access if user is the manager who created the project" do
      expect(subject).to permit(creator_manager, project)
    end

    it "denies access if user is another manager" do
      expect(subject).not_to permit(manager, project)
    end

    it "denies access if user is a tester" do
      expect(subject).not_to permit(tester, project)
    end
  end

  permissions :destroy? do
    it "grants access if user is admin" do
      expect(subject).to permit(admin, project)
    end

    it "denies access if user is manager" do
      expect(subject).not_to permit(manager, project)
      expect(subject).not_to permit(creator_manager, project)
    end

    it "denies access if user is tester" do
      expect(subject).not_to permit(tester, project)
    end
  end

  describe "Scope" do
     let!(:project1) { FactoryBot.create(:project, user: manager) }
     let!(:project2) { FactoryBot.create(:project, user: admin) } # Creat de admin, dar vizibil tuturor logati in scope-ul curent

     it "returns all projects for admin" do
        resolved_scope = described_class::Scope.new(admin, Project.all).resolve
        expect(resolved_scope).to contain_exactly(project1, project2)
     end

     it "returns all projects for manager" do # Conform implementării actuale
        resolved_scope = described_class::Scope.new(manager, Project.all).resolve
        expect(resolved_scope).to contain_exactly(project1, project2)
     end

     it "returns all projects for tester" do # Conform implementării actuale
        resolved_scope = described_class::Scope.new(tester, Project.all).resolve
        expect(resolved_scope).to contain_exactly(project1, project2)
     end

     it "returns no projects for nil user" do
        resolved_scope = described_class::Scope.new(nil, Project.all).resolve
        expect(resolved_scope).to be_empty
     end
   end
end