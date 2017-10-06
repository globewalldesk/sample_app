class AccountActivationsController < ApplicationController

  def edit 
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Your account has been activated. Welcome!"
      redirect_to user
    else
      flash[:danger] = "Activation link invalid, expired, or already used."
      redirect_to login_url
    end
  end

end
