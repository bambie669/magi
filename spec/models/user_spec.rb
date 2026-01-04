require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }
    # Devise handles email format and uniqueness validation implicitly

    describe "theme validation" do
      it { should validate_inclusion_of(:theme).in_array(User::THEMES) }

      it "accepts 'nerv' theme" do
        user = build(:user, theme: 'nerv')
        expect(user).to be_valid
      end

      it "accepts 'light' theme" do
        user = build(:user, theme: 'light')
        expect(user).to be_valid
      end

      it "rejects invalid theme" do
        user = build(:user, theme: 'invalid')
        expect(user).not_to be_valid
        expect(user.errors[:theme]).to be_present
      end
    end
  end

  describe "associations" do
    it { should have_many(:projects) }
    it { should have_many(:created_test_runs).class_name('TestRun').with_foreign_key('user_id') }
    it { should have_many(:executed_test_run_cases).class_name('TestRunCase').with_foreign_key('user_id') }
    it { should have_many(:api_tokens).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values(tester: 0, manager: 1, admin: 2) }
  end

  describe "defaults" do
    it "defaults role to :tester on initialization" do
      user = User.new
      expect(user.role).to eq("tester")
      expect(user.tester?).to be true
    end

    it "defaults theme to 'nerv'" do
      user = create(:user)
      expect(user.theme).to eq("nerv")
    end
  end

  describe "constants" do
    it "defines available themes" do
      expect(User::THEMES).to eq(%w[nerv light])
    end
  end

  describe "#display_name" do
    it "returns the email as display name" do
      user = build(:user, email: 'test@example.com')
      expect(user.display_name).to eq('test@example.com')
    end
  end
end