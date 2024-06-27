# frozen_string_literal: true

module Admin
  # Custom Doorkeeper::ApplicationsController
  # used in order to permit custom parameters
  # wiki: https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes
  class CustomApplicationsController < Doorkeeper::ApplicationsController
    private

    def application_params
      params.require(:doorkeeper_application)
            .permit(:name, :redirect_uri, :scopes, :confidential, :default_access)
    end
  end
end
