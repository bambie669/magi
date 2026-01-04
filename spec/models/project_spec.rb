require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    # Trebuie să creăm un user pentru a valida asocierea
    let(:user) { FactoryBot.create(:user) }
    subject { FactoryBot.build(:project, user: user) } # build pentru a testa validarea unicității

    it { should validate_presence_of(:name) }
    # Pentru a testa unicitatea, trebuie să creăm întâi un record
    it "validates uniqueness of name" do
       FactoryBot.create(:project, name: "Unique Project Name", user: user)
       should validate_uniqueness_of(:name)
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:milestones).dependent(:destroy) }
    it { should have_many(:test_suites).dependent(:destroy) }
    it { should have_many(:test_runs).dependent(:destroy) }
  end

  describe "#all_project_test_cases" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:test_suite) { create(:test_suite, project: project) }
    let(:test_scope) { create(:test_scope, test_suite: test_suite) }

    it "returns all test cases from all test suites" do
      test_case1 = create(:test_case, test_scope: test_scope)
      test_case2 = create(:test_case, test_scope: test_scope)

      expect(project.all_project_test_cases).to include(test_case1, test_case2)
    end

    it "returns empty array when no test cases exist" do
      expect(project.all_project_test_cases).to be_empty
    end
  end
end