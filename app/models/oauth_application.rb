class OauthApplication < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  has_many :app_admissions, dependent: :destroy
  validates :default_access, inclusion: { in: [true, false] }
  scope :default_access, -> { where(default_access: true) }
end
