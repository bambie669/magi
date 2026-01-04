require 'rails_helper'

RSpec.describe TestRun, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:test_suite) { create(:test_suite, project: project) }
  let(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let(:test_case) { create(:test_case, test_scope: test_scope) }

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "associations" do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:test_run_cases).dependent(:destroy) }
    it { should have_many(:test_cases).through(:test_run_cases) }
  end

  describe "factory" do
    it "creates a valid test run" do
      test_run = build(:test_run, project: project, user: user)
      expect(test_run).to be_valid
    end
  end

  describe "#add_test_cases" do
    let(:test_run) { create(:test_run, project: project, user: user) }
    let(:test_case2) { create(:test_case, test_scope: test_scope) }

    it "adds test cases to the test run" do
      test_run.add_test_cases([test_case.id, test_case2.id])
      expect(test_run.test_run_cases.count).to eq(2)
    end

    it "sets initial status to untested" do
      test_run.add_test_cases([test_case.id])
      expect(test_run.test_run_cases.first.status).to eq("untested")
    end

    it "does not create duplicates" do
      test_run.add_test_cases([test_case.id])
      test_run.add_test_cases([test_case.id])
      expect(test_run.test_run_cases.count).to eq(1)
    end
  end

  describe "statistics methods" do
    let(:test_run) { create(:test_run, project: project, user: user) }

    before do
      create(:test_run_case, test_run: test_run, test_case: test_case, status: :passed)
      create(:test_run_case, test_run: test_run, test_case: create(:test_case, test_scope: test_scope), status: :passed)
      create(:test_run_case, test_run: test_run, test_case: create(:test_case, test_scope: test_scope), status: :failed)
      create(:test_run_case, test_run: test_run, test_case: create(:test_case, test_scope: test_scope), status: :blocked)
      create(:test_run_case, test_run: test_run, test_case: create(:test_case, test_scope: test_scope), status: :untested)
    end

    describe "#total_cases" do
      it "returns total count of test run cases" do
        expect(test_run.total_cases).to eq(5)
      end
    end

    describe "#passed_cases" do
      it "returns count of passed cases" do
        expect(test_run.passed_cases).to eq(2)
      end
    end

    describe "#failed_cases" do
      it "returns count of failed cases" do
        expect(test_run.failed_cases).to eq(1)
      end
    end

    describe "#blocked_cases" do
      it "returns count of blocked cases" do
        expect(test_run.blocked_cases).to eq(1)
      end
    end

    describe "#untested_cases" do
      it "returns count of untested cases" do
        expect(test_run.untested_cases).to eq(1)
      end
    end

    describe "#completion_percentage" do
      it "calculates completion percentage" do
        # 4 out of 5 are tested (passed, passed, failed, blocked)
        expect(test_run.completion_percentage).to eq(80.0)
      end

      it "returns 0 when no cases" do
        empty_run = create(:test_run, project: project, user: user)
        expect(empty_run.completion_percentage).to eq(0)
      end
    end
  end
end
