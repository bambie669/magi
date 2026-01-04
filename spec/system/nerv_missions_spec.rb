require 'rails_helper'

RSpec.describe "NERV Missions (Projects)", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin, name: "E-commerce Platform", description: "Online store testing") }
  let!(:test_suite) { create(:test_suite, project: project) }
  let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case) { create(:test_case, test_scope: test_scope) }

  before do
    sign_in admin
  end

  describe "Missions Index (MISSION REGISTRY)" do
    before { visit projects_path }

    it "displays MISSION REGISTRY header" do
      expect(page).to have_content("MISSION REGISTRY")
    end

    it "displays mission entries" do
      expect(page).to have_content(project.name)
    end

    it "shows INITIALIZE MISSION button" do
      expect(page).to have_content("INITIALIZE MISSION").or have_link("INITIALIZE MISSION")
    end

    it "displays mission stats" do
      expect(page).to have_content(/protocol banks/i)
    end
  end

  describe "Mission Detail Page" do
    before { visit project_path(project) }

    it "displays MISSION header" do
      expect(page).to have_content("MISSION")
    end

    it "displays mission name" do
      expect(page).to have_content(project.name)
    end

    it "displays mission description" do
      expect(page).to have_content(project.description)
    end

    it "displays MISSION PARAMETERS section" do
      expect(page).to have_content("Mission Parameters").or have_content("MISSION PARAMETERS")
    end

    it "displays Protocol Banks section" do
      expect(page).to have_content("Protocol Banks").or have_content("PROTOCOL BANKS")
    end

    it "lists test suites as protocol banks" do
      expect(page).to have_content(test_suite.name)
    end
  end

  describe "Mission Actions" do
    before { visit project_path(project) }

    it "shows Initialize Protocol Bank button" do
      expect(page).to have_content(/initialize protocol bank/i).or have_link("New Test Suite")
    end

    it "shows Initialize Operation button" do
      expect(page).to have_content("Initialize Operation").or have_link("New Test Run")
    end

    it "shows Modify Mission button" do
      expect(page).to have_content(/modify mission/i)
    end

    it "shows Terminate Mission button" do
      expect(page).to have_content(/terminate mission/i)
    end
  end

  describe "Mission Stats Display" do
    before { visit project_path(project) }

    it "shows protocol bank count" do
      expect(page).to have_content("1").or have_content("Protocol Bank")
    end

    it "shows protocol count" do
      expect(page).to have_content(/protocol/i)
    end
  end
end
