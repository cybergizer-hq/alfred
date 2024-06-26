# frozen_string_literal: true

# Given oauth name and a user, returns array of first and last names
class UserNamePartitioner
  def initialize(user, auth_name)
    @user = user
    @auth_name = auth_name
  end

  def call
    return fullname if fullname.size.eql?(2)
    return [*fullname, ''] if [user.first_name, user.last_name].any?(&:blank?)
  end

  private

  attr_reader :user, :auth_name

  def fullname
    @fullname ||= auth_name.split(/[.\s]/, 2)
  end
end
