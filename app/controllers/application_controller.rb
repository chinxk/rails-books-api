# frozen_string_literal: true

# Books API Base Controller
class ApplicationController < ActionController::API
  protected

  def authenticate!
    render_failed and return unless token?
  # @current_user = User.find_by(id: auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render_failed
  end

  private

  def render_failed(messages = ['验证失败'])
    render json: { errors: messages }, status: :unauthorized
  end

  def http_token
    @http_token ||= (request.headers['Authorization'].split(' ').last if request.headers['Authorization'].present?)
  end

  def auth_token
    @auth_token ||= Token.decode(http_token)
  end

  def token?
    http_token && auth_token
  end
end
