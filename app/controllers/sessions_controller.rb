class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in.
      log_in(user)
      # In models/users.rb.
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to(user)
    else
      # Create an error message.
      if ! user
        flash.now[:danger] = "User not found."
      else
        flash.now[:danger] = "Password incorrect."
      end
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
