require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }
    # Devise handles email format and uniqueness validation implicitly
  end

  describe "associations" do
    it { should have_many(:projects) }
    it { should have_many(:created_test_runs).class_name('TestRun').with_foreign_key('user_id') }
    it { should have_many(:executed_test_run_cases).class_name('TestRunCase').with_foreign_key('user_id') }
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
  end
end