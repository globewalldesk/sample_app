module SessionsHelper
  
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # Remembers a user in a persistent session.
  def remember(user)
    user.remember # Creates remember token! Defined in models/user.rb.
    # Hashes ID and inserts it into cookies. 
    cookies.permanent.signed[:user_id] = user.id
     # Inserts newly-created remember token into cookies.
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end
  
  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find(user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      # .authenticated? is in models/users.rb.
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
  
  # Forgets a persistent session.
  def forget(user)
    user.forget # Deletes the remember token. Defined in models/user.rb.
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # Redirects to stored location (or to the default) after user logs in.
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default) # Default is the user_path.)
    session.delete(:forwarding_url)                  # Only forward once!
  end
  
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end