class AddDefaultAccessToOauthApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :default_access, :boolean, default: false, null: false
  end
end
