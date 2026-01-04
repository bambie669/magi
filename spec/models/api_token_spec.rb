require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { create(:api_token) }

    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
    it { should validate_presence_of(:name) }
  end

  describe "token generation" do
    it "auto-generates a token on create" do
      user = create(:user)
      api_token = ApiToken.create!(name: "Test Token", user: user)

      expect(api_token.token).to be_present
      expect(api_token.token.length).to eq(64) # SecureRandom.hex(32) generates 64 characters
    end

    it "does not overwrite an existing token" do
      user = create(:user)
      custom_token = "custom_token_value"
      api_token = ApiToken.create!(name: "Test Token", user: user, token: custom_token)

      expect(api_token.token).to eq(custom_token)
    end
  end

  describe "scopes" do
    describe ".active" do
      let(:user) { create(:user) }

      it "includes tokens without expiration" do
        token = create(:api_token, user: user, expires_at: nil)
        expect(ApiToken.active).to include(token)
      end

      it "includes tokens with future expiration" do
        token = create(:api_token, :long_lived, user: user)
        expect(ApiToken.active).to include(token)
      end

      it "excludes expired tokens" do
        token = create(:api_token, :expired, user: user)
        expect(ApiToken.active).not_to include(token)
      end
    end
  end

  describe "#expired?" do
    let(:user) { create(:user) }

    it "returns false when expires_at is nil" do
      token = create(:api_token, user: user, expires_at: nil)
      expect(token.expired?).to be false
    end

    it "returns false when expires_at is in the future" do
      token = create(:api_token, :long_lived, user: user)
      expect(token.expired?).to be false
    end

    it "returns true when expires_at is in the past" do
      token = create(:api_token, :expired, user: user)
      expect(token.expired?).to be true
    end
  end

  describe "#touch_last_used!" do
    it "updates the last_used_at timestamp" do
      token = create(:api_token)

      expect(token.last_used_at).to be_nil

      freeze_time do
        token.touch_last_used!
        expect(token.reload.last_used_at).to eq(Time.current)
      end
    end

    it "does not update other attributes" do
      token = create(:api_token)
      original_name = token.name

      token.touch_last_used!

      expect(token.reload.name).to eq(original_name)
    end
  end
end
