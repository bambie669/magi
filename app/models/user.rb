class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { tester: 0, manager: 1, admin: 2 }

  THEMES = %w[dark light].freeze
  validates :theme, inclusion: { in: THEMES }

  has_many :projects # Proiecte create de utilizator
  has_many :created_test_runs, class_name: 'TestRun', foreign_key: 'user_id'
  has_many :executed_test_run_cases, class_name: 'TestRunCase', foreign_key: 'user_id'
  has_many :api_tokens, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :test_case_templates, dependent: :destroy

  after_initialize :set_default_role, if: :new_record?

  validates :role, presence: true

  def set_default_role
    self.role ||= :tester
  end

  def display_name
    email # Sau adaugă câmpuri first_name/last_name
  end

  def unread_notifications_count
    notifications.unread.count
  end
end