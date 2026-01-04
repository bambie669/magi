require 'rails_helper'

RSpec.describe TestRunCase, type: :model do
  describe "associations" do
    it { should belong_to(:test_run) }
    it { should belong_to(:test_case) }
    it { should belong_to(:user).optional }
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:test_suite) { create(:test_suite, project: project) }
    let(:test_scope) { create(:test_scope, test_suite: test_suite) }
    let(:test_case) { create(:test_case, test_scope: test_scope) }
    let(:test_run) { create(:test_run, project: project, user: user) }
    let!(:existing_test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case) }

    it "validates uniqueness of test_case within test_run" do
      duplicate = build(:test_run_case, test_run: test_run, test_case: test_case)
      expect(duplicate).not_to be_valid
    end
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(untested: 0, passed: 1, failed: 2, blocked: 3) }
  end

  describe "attachments" do
    let(:test_run_case) { create(:test_run_case) }

    it "can have attachments" do
      expect(test_run_case).to respond_to(:attachments)
    end
  end

  describe "factory" do
    it "creates a valid test run case" do
      test_run_case = build(:test_run_case)
      expect(test_run_case).to be_valid
    end
  end
end
