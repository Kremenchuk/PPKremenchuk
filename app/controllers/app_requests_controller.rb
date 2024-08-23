class AppRequestsController < ApplicationController
  
  def index
    @app_requests = AppRequest.where(created_at: (Time.now - 24.hours)..Time.now)
  end
end
