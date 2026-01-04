require 'rails_helper'

RSpec.describe "NERV Visual Theme", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, user: admin) }
  let!(:test_suite) { create(:test_suite, project: project) }
  let!(:test_case) { create(:test_case, test_suite: test_suite) }
  let!(:test_run) { create(:test_run, project: project, user: admin) }
  let!(:test_run_case) { create(:test_run_case, test_run: test_run, test_case: test_case, status: :passed) }

  before do
    sign_in admin
  end

  describe "Global Theme Elements" do
    before { visit dashboard_path }

    it "has dark background theme" do
      expect(page).to have_css("body[class*='bg-nerv']").or have_css("body[class*='nerv']")
    end

    it "has NERV panel components" do
      expect(page).to have_css(".nerv-panel")
    end

    it "has NERV panel headers" do
      expect(page).to have_css(".nerv-panel-header")
    end

    it "has terminal-style typography" do
      expect(page).to have_css("[class*='font-mono']")
    end

    it "has uppercase tracking for labels" do
      expect(page).to have_css("[class*='uppercase']")
    end
  end

  describe "Color Palette Usage" do
    before { visit dashboard_path }

    it "uses terminal-cyan for data values" do
      expect(page).to have_css("[class*='terminal-cyan']")
    end

    it "uses terminal-white for text" do
      expect(page).to have_css("[class*='terminal-white']")
    end

    it "uses terminal-gray for secondary text" do
      expect(page).to have_css("[class*='terminal-gray']")
    end

    it "uses terminal-red for accents/dividers" do
      expect(page).to have_css("[class*='terminal-red']")
    end
  end

  describe "Button Styling" do
    before { visit projects_path }

    it "has NERV primary button style" do
      expect(page).to have_css(".btn-nerv-primary").or have_css("[class*='btn-nerv']")
    end
  end

  describe "Layout Structure" do
    before { visit dashboard_path }

    it "has sidebar navigation" do
      expect(page).to have_css("aside")
    end

    it "has main content area" do
      expect(page).to have_css("main")
    end

    it "has system footer" do
      expect(page).to have_css("footer")
    end
  end

  describe "NERV Specific Styling" do
    before { visit dashboard_path }

    it "has red accent lines/borders" do
      expect(page).to have_css("[class*='border-terminal-red']")
    end

    it "has purple background elements" do
      expect(page).to have_css("[class*='nerv-purple']").or have_css("[class*='bg-nerv']")
    end
  end

  describe "Responsive Navigation" do
    before { visit dashboard_path }

    it "sidebar has proper structure" do
      within("aside") do
        expect(page).to have_css("nav").or have_css("a")
      end
    end

    it "navigation links are functional" do
      within("aside nav") do
        expect(page).to have_content("COMMAND OVERVIEW")
        expect(page).to have_content("OPERATIONS")
        expect(page).to have_content("MISSIONS")
      end
    end
  end

  describe "Animation Classes" do
    before { visit dashboard_path }

    it "has CSS animations available" do
      # Check that the page has animation classes defined
      expect(page).to have_css("[class*='animate']").or have_css("[class*='glow']").or have_css("[class*='pulse']")
    end
  end
end
