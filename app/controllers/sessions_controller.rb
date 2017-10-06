class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.activated? && @user.authenticate(params[:session][:password])
      # Log the user in.
      log_in(@user)
      # In models/users.rb.
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_back_or @user
    else
      # Create an error message depending on the problem.
      flash.now[:danger] = 
        if ! @user
          "User not found."
        elsif ! @user.authenticate(params[:session][:password])
          "Password incorrect."
        elsif ! @user.activated?
          "Account not activated."
        end
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
