require 'rails_helper'

RSpec.describe "NERV Operations (Test Runs)", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }
  let!(:test_suite) { create(:test_suite, project: project) }
  let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case) { create(:test_case, test_scope: test_scope) }
  let!(:test_run) { create(:test_run, project: project, user: admin, name: "Regression Test Alpha") }
  let!(:test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case, status: :passed) }

  before do
    sign_in admin
  end

  describe "Operations Index (OPERATIONS REGISTRY)" do
    before { visit test_runs_path }

    it "displays OPERATIONS REGISTRY header" do
      expect(page).to have_content("OPERATIONS REGISTRY")
    end

    it "displays operation entries" do
      expect(page).to have_content(test_run.name)
    end

    it "shows INITIALIZE OPERATION button when project is set" do
      # The button only appears when project context is set
      visit project_test_runs_path(project)
      expect(page).to have_content("INITIALIZE OPERATION")
    end
  end

  describe "Operation Detail (OPERATION DETAIL)" do
    before { visit test_run_path(test_run) }

    it "displays OPERATION header" do
      expect(page).to have_content("OPERATION")
    end

    it "displays MISSION CONTEXT section" do
      expect(page).to have_content("MISSION CONTEXT")
    end

    it "displays OPERATION COMMANDER section" do
      expect(page).to have_content("OPERATION COMMANDER")
    end

    it "displays PROTOCOL EXECUTION section" do
      expect(page).to have_content("PROTOCOL EXECUTION")
    end

    it "displays protocol details" do
      expect(page).to have_content(test_case.title)
    end
  end

  describe "MAGI Consensus Panel" do
    before { visit test_run_path(test_run) }

    it "displays MAGI CONSENSUS header" do
      expect(page).to have_content("MAGI CONSENSUS")
    end

    it "displays CASPER computer" do
      expect(page).to have_content("CASPER")
    end

    it "displays BALTHASAR computer" do
      expect(page).to have_content("BALTHASAR")
    end

    it "displays MELCHIOR computer" do
      expect(page).to have_content("MELCHIOR")
    end
  end

  describe "Status Terminology" do
    context "when test is passed" do
      before do
        test_run_case.update!(status: :passed)
        visit test_run_path(test_run)
      end

      it "shows NOMINAL status" do
        expect(page).to have_content("NOMINAL")
      end
    end

    context "when test is failed" do
      before do
        test_run_case.update!(status: :failed)
        visit test_run_path(test_run)
      end

      it "shows BREACH status" do
        expect(page).to have_content("BREACH")
      end
    end

    context "when test is blocked" do
      before do
        test_run_case.update!(status: :blocked)
        visit test_run_path(test_run)
      end

      it "shows PATTERN BLUE status" do
        expect(page).to have_content("PATTERN BLUE")
      end
    end

    context "when test is untested" do
      before do
        test_run_case.update!(status: :untested)
        visit test_run_path(test_run)
      end

      it "shows STANDBY status" do
        expect(page).to have_content("STANDBY")
      end
    end
  end

  describe "Action Buttons" do
    before { visit test_run_path(test_run) }

    it "shows MODIFY OPERATION button" do
      expect(page).to have_content("MODIFY OPERATION").or have_link("Modify Operation")
    end

    it "shows TERMINATE OPERATION button" do
      expect(page).to have_content("TERMINATE OPERATION").or have_button("Terminate Operation")
    end
  end
end
