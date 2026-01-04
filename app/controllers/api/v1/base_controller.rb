module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_api_token!

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      private

      def authenticate_api_token!
        token = extract_token_from_header
        @api_token = ApiToken.active.find_by(token: token)

        unless @api_token
          render json: { error: 'Unauthorized - Invalid or expired token' }, status: :unauthorized
          return
        end

        @api_token.touch_last_used!
      end

      def extract_token_from_header
        auth_header = request.headers['Authorization']
        return nil unless auth_header

        auth_header.gsub(/^Bearer\s+/i, '')
      end

      def current_user
        @api_token&.user
      end

      def user_not_authorized
        render json: { error: 'Forbidden - You do not have permission to perform this action' }, status: :forbidden
      end

      def record_not_found
        render json: { error: 'Not Found' }, status: :not_found
      end
    end
  end
end
