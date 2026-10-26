class User < ApplicationRecord
  has_many :app_admissions, dependent: :destroy
  has_many :oauth_applications, through: :app_admissions
  accepts_nested_attributes_for :app_admissions

  validates :dob, presence: true

  after_commit :add_default_avatar, on: %i[create update]
  before_save :downcase_emails
  after_save :revoke_oauth_credentials, if: :just_deactivated?

  devise :omniauthable, :lockable, :trackable

  has_one_attached :avatar

  def self.from_omniauth(auth)
    OmniauthUserService.new(auth).call
  end

  def admin?
    is_admin
  end

  def active_for_authentication?
    super && !deactivated?
  end

  def deactivated?
    deactivated_at.present?
  end

  private

  def just_deactivated?
    saved_change_to_deactivated_at? && deactivated?
  end

  # Runs inside the save transaction, so the user is never left deactivated
  # with live tokens. Grants are revoked too, so an authorization code issued
  # just before deactivation can't be exchanged for a fresh token.
  def revoke_oauth_credentials
    now = Time.current
    Doorkeeper::AccessToken.where(resource_owner_id: id, revoked_at: nil).update_all(revoked_at: now)
    Doorkeeper::AccessGrant.where(resource_owner_id: id, revoked_at: nil).update_all(revoked_at: now)
  end

  def downcase_emails
    self.email = email.downcase
    self.alternative_email = alternative_email&.downcase
  end

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(Rails.root.join('app/assets/images/default.png')),
      filename: 'default.jpg',
      content_type: 'image/png'
    )
  end
end
