require 'rails_helper'

RSpec.describe "NERV Protocols (Test Cases)", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }
  let!(:test_suite) { create(:test_suite, project: project, name: "Security Suite") }
  let!(:test_scope) { create(:test_scope, test_suite: test_suite) }
  let!(:test_case) do
    create(:test_case,
      test_scope: test_scope,
      title: "TC-AUTH-001: Valid User Login",
      preconditions: "User account exists and is active",
      steps: "1. Navigate to Login page\n2. Enter credentials\n3. Click Login",
      expected_result: "User is logged in successfully"
    )
  end

  before do
    sign_in admin
  end

  describe "Protocol Detail Page" do
    before { visit test_case_path(test_case) }

    it "displays PROTOCOL header with ID" do
      expect(page).to have_content("PROTOCOL")
    end

    it "displays protocol title" do
      expect(page).to have_content(test_case.title, normalize_ws: true).or have_content(test_case.title.upcase)
    end

    it "displays PRECONDITIONS section" do
      expect(page).to have_content("PRECONDITIONS")
    end

    it "displays EXECUTION STEPS section" do
      expect(page).to have_content("EXECUTION STEPS")
    end

    it "displays EXPECTED OUTCOME section" do
      expect(page).to have_content("EXPECTED OUTCOME")
    end

    it "shows preconditions content" do
      expect(page).to have_content(test_case.preconditions)
    end

    it "shows expected result content" do
      expect(page).to have_content(test_case.expected_result)
    end
  end

  describe "Protocol Bank (Test Suite)" do
    before { visit test_suite_path(test_suite) }

    it "displays PROTOCOL BANK header" do
      expect(page).to have_content("PROTOCOL BANK")
    end

    it "displays Bank Overview section" do
      expect(page).to have_content("BANK OVERVIEW")
    end

    it "shows protocol count" do
      expect(page).to have_content(/protocols/i)
    end

    it "lists protocols in the bank" do
      expect(page).to have_content(test_case.title)
    end

    it "shows New Protocol button" do
      expect(page).to have_content(/new protocol/i).or have_content(/initialize protocol/i)
    end

    it "has Modify Bank action" do
      # Button is now an icon in header with title attribute
      expect(page).to have_css("[title='Modify Bank']")
    end

    it "has Purge Bank action" do
      # Button is now an icon in header with title attribute
      expect(page).to have_css("[title='Purge Bank']")
    end
  end

  describe "Protocol Form" do
    before { visit new_test_suite_test_case_path(test_suite) }

    it "displays INITIALIZE PROTOCOL header" do
      expect(page).to have_content("INITIALIZE PROTOCOL").or have_content("New Protocol")
    end

    it "has Protocol Designation field" do
      expect(page).to have_field("test_case[title]").or have_content("Protocol Designation")
    end

    it "has Preconditions field" do
      expect(page).to have_field("test_case[preconditions]").or have_content("Preconditions")
    end

    it "has Execution Steps field" do
      expect(page).to have_field("test_case[steps]").or have_content("Execution Steps")
    end

    it "has Expected Outcome field" do
      expect(page).to have_field("test_case[expected_result]").or have_content("Expected Outcome")
    end

    it "has Initialize Protocol submit button" do
      expect(page).to have_button("Initialize Protocol").or have_button("Create")
    end
  end
end
