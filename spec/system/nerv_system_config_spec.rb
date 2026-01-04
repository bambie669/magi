require 'rails_helper'

RSpec.describe "NERV System Config", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:tester) { create(:user, role: :tester) }

  describe "Theme Section" do
    before do
      sign_in admin
      visit system_config_path
    end

    it "displays SYSTEM CONFIGURATION header" do
      expect(page).to have_content("SYSTEM CONFIGURATION")
    end

    it "displays Theme tab" do
      expect(page).to have_content(/theme/i)
    end

    it "displays Documentation tab" do
      expect(page).to have_content(/documentation/i)
    end

    it "displays Glossary tab" do
      expect(page).to have_content(/glossary/i)
    end

    it "displays Operators tab for admin" do
      expect(page).to have_content(/operators/i)
    end

    it "shows EVA-01 UNIT theme option" do
      expect(page).to have_content("EVA-01 UNIT")
      expect(page).to have_content("Shinji's Unit - Purple & Green")
    end

    it "shows EVA-00 UNIT theme option" do
      expect(page).to have_content("EVA-00 UNIT")
      expect(page).to have_content("Rei's Unit - Blue, White & Orange")
    end
  end

  describe "Theme Section for non-admin" do
    before do
      sign_in tester
      visit system_config_path
    end

    it "does not display Operators tab for non-admin" do
      expect(page).not_to have_link("Operators")
    end
  end

  describe "Operators Section" do
    let!(:other_user) { create(:user, email: "operator@nerv.org", role: :tester) }

    before do
      sign_in admin
      visit system_config_path(section: 'operators')
    end

    it "displays OPERATOR REGISTRY header" do
      expect(page).to have_content("OPERATOR REGISTRY")
    end

    it "displays Initialize Operator button" do
      expect(page).to have_content(/initialize operator/i)
    end

    it "shows operator list" do
      expect(page).to have_content(admin.email)
      expect(page).to have_content(other_user.email)
    end

    it "shows clearance levels" do
      expect(page).to have_content("ADMIN")
      expect(page).to have_content("TESTER")
    end
  end

  describe "New Operator Form" do
    before do
      sign_in admin
      visit new_operator_path
    end

    it "displays INITIALIZE NEW OPERATOR header" do
      expect(page).to have_content("INITIALIZE NEW OPERATOR")
    end

    it "has email field" do
      expect(page).to have_field("user[email]")
    end

    it "has role select" do
      expect(page).to have_select("user[role]")
    end

    it "has password field" do
      expect(page).to have_field("user[password]")
    end

    it "has Initialize Operator button" do
      expect(page).to have_button("Initialize Operator")
    end
  end

  describe "Documentation Section" do
    before do
      sign_in admin
      visit system_config_path(section: 'documentation')
    end

    it "displays MAGI SYSTEM OVERVIEW" do
      expect(page).to have_content("MAGI SYSTEM OVERVIEW")
    end

    it "displays SYSTEM HIERARCHY" do
      expect(page).to have_content("SYSTEM HIERARCHY")
    end

    it "displays OPERATOR CLEARANCE LEVELS" do
      expect(page).to have_content("OPERATOR CLEARANCE LEVELS")
    end

    it "displays QUICK ACTION GUIDE" do
      expect(page).to have_content("QUICK ACTION GUIDE")
    end

    it "explains the hierarchy" do
      expect(page).to have_content("Mission")
      expect(page).to have_content("Protocol Bank")
      expect(page).to have_content("Protocol")
      expect(page).to have_content("Operation")
    end
  end

  describe "Glossary Section" do
    before do
      sign_in admin
      visit system_config_path(section: 'glossary')
    end

    it "displays NERV TERMINOLOGY GLOSSARY" do
      expect(page).to have_content("NERV TERMINOLOGY GLOSSARY")
    end

    it "includes NERV terminology" do
      expect(page).to have_content("Command Overview")
      expect(page).to have_content("Mission")
      expect(page).to have_content("Protocol")
      expect(page).to have_content("Protocol Bank")
      expect(page).to have_content("Operation")
    end

    it "includes status terminology" do
      expect(page).to have_content(/nominal/i)
      expect(page).to have_content(/breach/i)
      expect(page).to have_content(/pattern blue/i)
      expect(page).to have_content(/standby/i)
    end

    it "includes action verbs" do
      expect(page).to have_content("Initialize")
      expect(page).to have_content("Modify")
      expect(page).to have_content("Terminate")
    end
  end

  describe "Sidebar navigation" do
    before do
      sign_in admin
      visit authenticated_root_path
    end

    it "shows System Config link in sidebar" do
      within('aside') do
        expect(page).to have_content(/system config/i)
      end
    end
  end
end
