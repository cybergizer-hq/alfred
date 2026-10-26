module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user!
      before_action :doorkeeper_authorize!
      before_action :reject_inactive_resource_owner

      def me
        render json: {
          id: current_resource_owner.id,
          uid: current_resource_owner.uid,
          first_name: current_resource_owner.first_name,
          last_name: current_resource_owner.last_name,
          email: current_resource_owner.email,
          dob: current_resource_owner.dob,
          avatar: current_resource_owner.avatar.service_url
        }.to_json
      end

      private

      def current_resource_owner
        return unless doorkeeper_token

        @current_resource_owner ||= User.find_by(id: doorkeeper_token.resource_owner_id)
      end

      # Deactivation revokes tokens, but this also catches owners deactivated
      # without callbacks (update_column, SQL) and tokens whose owner was deleted.
      def reject_inactive_resource_owner
        return if current_resource_owner&.active_for_authentication?

        render json: { error: 'invalid_token', error_description: 'The access token is no longer valid.' },
               status: :unauthorized
      end
    end
  end
end
