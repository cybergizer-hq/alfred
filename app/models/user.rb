class User < ApplicationRecord
  has_many :app_admissions, dependent: :destroy
  has_many :oauth_applications, through: :app_admissions
  accepts_nested_attributes_for :app_admissions

  validates :dob, presence: true

  after_commit :add_default_avatar, on: %i[create update]

  devise :omniauthable, :lockable, :trackable

  has_one_attached :avatar

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.email = auth.info.email
      fullname = auth.info.name.split(/[.\s]/, 2)
      user.first_name, user.last_name = fullname.size.eql?(2) ? fullname : [*fullname, ''] if [user.first_name, user.last_name].any?(&:blank?)

      user.save
    end
  end

  def admin?
    is_admin
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
