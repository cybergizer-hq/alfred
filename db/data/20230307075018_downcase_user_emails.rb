# frozen_string_literal: true

class DowncaseUserEmails < ActiveRecord::Migration[6.1]
  def up
    User.all.each { |user| user.save }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
