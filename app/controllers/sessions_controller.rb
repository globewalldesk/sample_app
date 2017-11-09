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
      if ! @user
        flash.now[:danger] ="User not found."
      elsif ! @user.authenticate(params[:session][:password])
        flash.now[:danger] = "Password incorrect."
      elsif ! @user.activated?
        # Gives the user a handy reactivation button right in the flash.
        flash.now[:danger] = "Hi #{@user.name}! You need to activate your 
                              account before you can log in. 
                              #{view_context.link_to('Want a new activation 
                              email?', reactivate_user_path(@user), 
                              method: :post)}"
      end
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
