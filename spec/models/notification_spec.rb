require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:notifiable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:notification_type) }
    it { should validate_presence_of(:message) }
    it { should validate_inclusion_of(:notification_type).in_array(Notification::TYPES) }
  end

  describe 'scopes' do
    let!(:unread_notification) { create(:notification) }
    let!(:read_notification) { create(:notification, :read) }

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(Notification.unread).to include(unread_notification)
        expect(Notification.unread).not_to include(read_notification)
      end
    end

    describe '.read' do
      it 'returns only read notifications' do
        expect(Notification.read).to include(read_notification)
        expect(Notification.read).not_to include(unread_notification)
      end
    end
  end

  describe '#read?' do
    it 'returns true when read_at is present' do
      notification = build(:notification, read_at: Time.current)
      expect(notification.read?).to be true
    end

    it 'returns false when read_at is nil' do
      notification = build(:notification, read_at: nil)
      expect(notification.read?).to be false
    end
  end

  describe '#mark_as_read!' do
    it 'sets read_at to current time' do
      notification = create(:notification)
      expect { notification.mark_as_read! }.to change { notification.read? }.from(false).to(true)
    end

    it 'does not update if already read' do
      notification = create(:notification, :read)
      original_read_at = notification.read_at
      notification.mark_as_read!
      expect(notification.read_at).to eq(original_read_at)
    end
  end

  describe '#type_label' do
    it 'returns Test Run Complete for test_run_completed' do
      notification = build(:notification, notification_type: 'test_run_completed')
      expect(notification.type_label).to eq('Test Run Complete')
    end

    it 'returns Test Failed for test_case_failed' do
      notification = build(:notification, notification_type: 'test_case_failed')
      expect(notification.type_label).to eq('Test Failed')
    end
  end

  describe '#type_class' do
    it 'returns status-success for test_run_completed' do
      notification = build(:notification, notification_type: 'test_run_completed')
      expect(notification.type_class).to eq('text-status-success')
    end

    it 'returns status-error for test_case_failed' do
      notification = build(:notification, notification_type: 'test_case_failed')
      expect(notification.type_class).to eq('text-status-error')
    end
  end
end
