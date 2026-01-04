require 'rails_helper'

RSpec.describe "NERV Sidebar (COMMAND CORE)", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }

  before do
    sign_in admin
  end

  describe "NERV Branding" do
    it "displays the NERV logo/title" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("NERV")
      end
    end

    it "displays the MAGI subtitle" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("MAGI QA SYSTEM")
      end
    end

    it "displays the NERV motto" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("GOD'S IN HIS HEAVEN")
        expect(page).to have_content("ALL'S RIGHT WITH THE WORLD")
      end
    end
  end

  describe "Navigation Terminology" do
    it "uses COMMAND OVERVIEW instead of Dashboard" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_link("COMMAND OVERVIEW")
      end
    end

    it "uses OPERATIONS instead of Test Runs" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_link("OPERATIONS")
      end
    end

    it "uses MISSIONS instead of Projects" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_link("MISSIONS")
      end
    end
  end

  describe "User Section" do
    it "displays OPERATOR label for user" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("OPERATOR")
      end
    end

    it "displays CLEARANCE label for role" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("CLEARANCE")
      end
    end

    it "shows admin clearance level" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content("ADMIN")
      end
    end
  end

  describe "Active Projects Section" do
    it "displays Active Missions section" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content(/active missions/i)
      end
    end

    it "lists project names" do
      visit dashboard_path
      within("aside") do
        expect(page).to have_content(project.name)
      end
    end
  end
end
