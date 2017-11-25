class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    unless @user.activated?
      flash[:danger] = "Sorry, #{@user.name}'s account has not been activated."
      redirect_to root_url
    end
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    victim = User.find(params[:id])
    victim.destroy
    flash[:success] = "User #{victim.name} deleted."
    redirect_to users_url
  end
    
  # Resends activation email. This has its own 'reactivate' route (see 
  # routes.rb) and the route is followed only via a link, contained in an error 
  # flash, found at sessions_controller.rb.
  def reactivate
    @user = User.find(params[:id])
    @user.create_activation_digest
    @user.update_attribute(:activation_digest, @user.activation_digest)
    @user.send_activation_email
    flash[:info] = "Click the activation link we just emailed you, 
                    and we'll log you in."
    redirect_to root_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    
    def user_params
      params.require(:user).permit(:name, :email, 
                                   :password, :password_confirmation)
    end
    
    # Before filters 
    # because these "filter" the controller for access
    
    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = 
          "You do not have permission to access #{@user.name}'s account."
        redirect_to(root_url)
      end
    end
    
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
