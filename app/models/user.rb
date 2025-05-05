class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { tester: 0, manager: 1, admin: 2 }

  has_many :projects # Proiecte create de utilizator
  has_many :created_test_runs, class_name: 'TestRun', foreign_key: 'user_id'
  has_many :executed_test_run_cases, class_name: 'TestRunCase', foreign_key: 'user_id'

  after_initialize :set_default_role, if: :new_record?

  validates :role, presence: true

  def set_default_role
    self.role ||= :tester
  end

  def display_name
    email # Sau adaugă câmpuri first_name/last_name
  end
end