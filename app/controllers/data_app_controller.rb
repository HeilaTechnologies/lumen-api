class DataAppController < ApplicationController
  before_action :authenticate_user!

  # GET /app/:id.json
  def show
    @app = DataApp.find(params[:id])
    @nilm = @app.nilm
    head :unauthorized and return unless current_user.views_nilm?(@nilm)
    # destroy any existing tokens
    InterfaceAuthToken.where(user: current_user, data_app: @app).destroy_all

    @auth_url = _app_auth_url
  end

  private

  def _app_auth_url
    return "#" unless request.headers.key?("HTTP_X_APP_BASE_URI") # apps not enabled
    token = InterfaceAuthToken.create(data_app: @app,
                                      user: current_user, expiration: 5.minutes.from_now)
    base = request.headers["HTTP_X_APP_BASE_URI"]
    "#{base}/#{token.data_app.id}/?auth_token=#{token.value}"
  end

end