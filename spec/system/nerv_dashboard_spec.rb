require 'rails_helper'

RSpec.describe "NERV Dashboard (COMMAND OVERVIEW)", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }
  let!(:test_suite) { create(:test_suite, project: project) }
  let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case) { create(:test_case, test_scope: test_scope) }
  let!(:test_run) { create(:test_run, project: project, user: admin) }

  before do
    sign_in admin
    visit dashboard_path
  end

  describe "Page Header" do
    it "displays PRIMARY CONTROL INTERFACE title" do
      expect(page).to have_content("PRIMARY CONTROL INTERFACE")
    end

    it "displays MAGI System status" do
      expect(page).to have_content(/magi system online/i)
    end
  end

  describe "Statistics Panels" do
    it "displays ACTIVE OPS panel" do
      expect(page).to have_content("ACTIVE OPS")
    end

    it "displays PROTOCOLS panel" do
      expect(page).to have_content("PROTOCOLS")
    end

    it "displays MISSIONS panel" do
      expect(page).to have_content("MISSIONS")
    end

    it "displays SYSTEM INTEGRITY panel" do
      expect(page).to have_content("SYSTEM INTEGRITY")
    end
  end

  describe "Recent Activity Section" do
    it "displays RECENT OPERATIONS section" do
      expect(page).to have_content("RECENT OPERATIONS")
    end
  end

  describe "System Footer" do
    it "displays NERV HEADQUARTERS footer" do
      expect(page).to have_content("NERV HEADQUARTERS")
    end

    it "displays MAGI QA INTERFACE version" do
      expect(page).to have_content("MAGI QA INTERFACE")
    end

    it "displays SYSTEM TIME" do
      expect(page).to have_content("SYSTEM TIME")
    end
  end

  describe "Visual Elements" do
    it "has terminal-style panels with proper styling" do
      # Check for NERV panel classes
      expect(page).to have_css(".nerv-panel")
    end

    it "has nerv-panel-header elements" do
      expect(page).to have_css(".nerv-panel-header")
    end
  end
end
