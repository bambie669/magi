require 'rails_helper'

RSpec.describe SystemConfigPolicy, type: :policy do
  subject { described_class.new(user, :system_config) }

  describe "manage_operators?" do
    context "when user is admin" do
      let(:user) { create(:user, :admin) }

      it "permits managing operators" do
        expect(subject.manage_operators?).to be true
      end
    end

    context "when user is manager" do
      let(:user) { create(:user, role: :manager) }

      it "denies managing operators" do
        expect(subject.manage_operators?).to be false
      end
    end

    context "when user is tester" do
      let(:user) { create(:user, role: :tester) }

      it "denies managing operators" do
        expect(subject.manage_operators?).to be false
      end
    end

    context "when user is nil" do
      let(:user) { nil }

      it "denies managing operators" do
        expect(subject.manage_operators?).to be false
      end
    end
  end
end
