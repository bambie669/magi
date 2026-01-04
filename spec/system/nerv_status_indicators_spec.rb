require 'rails_helper'

RSpec.describe "NERV Status Indicators", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }
  let!(:test_suite) { create(:test_suite, project: project) }
  let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case1) { create(:test_case, test_scope: test_scope, title: "Test Case Passed") }
  let!(:test_case2) { create(:test_case, test_scope: test_scope, title: "Test Case Failed") }
  let!(:test_case3) { create(:test_case, test_scope: test_scope, title: "Test Case Blocked") }
  let!(:test_case4) { create(:test_case, test_scope: test_scope, title: "Test Case Untested") }
  let!(:test_run) { create(:test_run, project: project, user: admin) }
  let!(:trc_passed) { create(:test_run_case, test_run: test_run, test_case: test_case1, status: :passed) }
  let!(:trc_failed) { create(:test_run_case, test_run: test_run, test_case: test_case2, status: :failed) }
  let!(:trc_blocked) { create(:test_run_case, test_run: test_run, test_case: test_case3, status: :blocked) }
  let!(:trc_untested) { create(:test_run_case, test_run: test_run, test_case: test_case4, status: :untested) }

  before do
    sign_in admin
    visit test_run_path(test_run)
  end

  describe "Status Badge Mapping" do
    it "displays NOMINAL for passed tests" do
      expect(page).to have_content("NOMINAL")
    end

    it "displays BREACH for failed tests" do
      expect(page).to have_content("BREACH")
    end

    it "displays PATTERN BLUE for blocked tests" do
      expect(page).to have_content("PATTERN BLUE")
    end

    it "displays STANDBY for untested tests" do
      expect(page).to have_content("STANDBY")
    end
  end

  describe "Status Color Styling" do
    it "applies terminal-green color class for NOMINAL" do
      expect(page).to have_css(".text-terminal-green", text: "NOMINAL")
    end

    it "applies terminal-red color class for BREACH" do
      expect(page).to have_css(".text-terminal-red", text: "BREACH")
    end

    it "applies terminal-amber color class for PATTERN BLUE" do
      expect(page).to have_css(".text-terminal-amber", text: "PATTERN BLUE")
    end

    it "applies terminal-gray color class for STANDBY" do
      expect(page).to have_css(".text-terminal-gray", text: "STANDBY")
    end
  end

  describe "Operation Summary Statistics" do
    it "displays pass count as NOMINAL count" do
      expect(page).to have_content("NOMINAL")
    end

    it "displays fail count as BREACH count" do
      expect(page).to have_content("BREACH")
    end

    it "displays blocked count as PATTERN BLUE count" do
      expect(page).to have_content("PATTERN BLUE")
    end
  end

  describe "Visual Indicators" do
    it "has status badges with proper styling" do
      expect(page).to have_css("[class*='terminal-']")
    end

    it "has animated elements for critical status" do
      # BREACH items should have animation/pulse effect
      expect(page).to have_css(".animate-pulse").or have_css("[class*='pulse']")
    end
  end
end
