require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    # Trebuie să creăm un user pentru a valida asocierea
    let(:user) { FactoryBot.create(:user) }
    subject { FactoryBot.build(:project, user: user) } # build pentru a testa validarea unicității

    it { should validate_presence_of(:name) }
    # Pentru a testa unicitatea, trebuie să creăm întâi un record
    it "validates uniqueness of name" do
       FactoryBot.create(:project, name: "Unique Project Name", user: user)
       should validate_uniqueness_of(:name)
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:milestones).dependent(:destroy) }
    it { should have_many(:test_suites).dependent(:destroy) }
    it { should have_many(:test_cases).through(:test_suites) }
    it { should have_many(:test_runs).dependent(:destroy) }
  end
end