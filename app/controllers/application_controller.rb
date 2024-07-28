class ApplicationController < ActionController::API

  def current_user
    @current_user ||= Session.find_by(token: request.headers['x-session-token']).try(:user)
  rescue
    nil
  end

  def authorize
    render(:json => {}, :status => 401) unless current_user
  end

end
