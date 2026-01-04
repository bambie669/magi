require 'rails_helper'

RSpec.describe Milestone, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:due_date) }
  end

  describe "associations" do
    it { should belong_to(:project) }
  end

  describe "factory" do
    it "creates a valid milestone" do
      milestone = build(:milestone)
      expect(milestone).to be_valid
    end
  end
end
