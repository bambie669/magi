require 'rails_helper'

RSpec.describe TestCaseTemplate, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:user) }
  end

  describe '#to_test_case_attributes' do
    it 'returns attributes for creating a test case' do
      template = build(:test_case_template,
        name: 'Login Test',
        preconditions: 'User is logged out',
        steps: '1. Go to login page',
        expected_result: 'User is logged in'
      )

      attrs = template.to_test_case_attributes

      expect(attrs[:title]).to eq('Login Test')
      expect(attrs[:preconditions]).to eq('User is logged out')
      expect(attrs[:steps]).to eq('1. Go to login page')
      expect(attrs[:expected_result]).to eq('User is logged in')
    end
  end
end
