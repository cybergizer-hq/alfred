# frozen_string_literal: true

class DowncaseUserEmails < ActiveRecord::Migration[6.1]
  def up
    User.all.each do |user|
      user.update_attribute(:email, user.email.downcase)
      user.update_attribute(:alternative_email, user.alternative_email&.downcase)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
