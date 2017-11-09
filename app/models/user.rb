class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email # downcases email before saving so case-sensitive indexers don't break
  before_create :create_activation_digest
  validates :name,  presence: true,  length: { maximum: 50 } # auto-validation, very cool
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i   # used to check that input email is hip to the groove
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }    # since emails must be unique, checks before saving
  has_secure_password
  validates :password, length: { minimum: 6 }
  validates :password, format: { with: /[a-z]/, message: "needs at least one lowercase letter" }
  validates :password, format: { with: /[A-Z]/, message: "needs at least one lowercase letter" }
  validates :password, format: { with: /\d/, message: "needs at least one number" }
  
  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    # Returns a random token. Note, this is a class method; doesn't depend on any particular user.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end # Of class methods.
  
  # Remembers a user in the database for use in persistent sessions.
  # This is used in sessions_controller.rb via sessions_helper.rb.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Forgets a user.
  def forget
    # Deletes the remember digest from the database.
    # That could explain why this is here rather than in sessions_helper.rb,
    # where it is used.
    update_attribute(:remember_digest, nil)
  end
  
  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # Sends activation email.
  def send_activation_email
    # Opens mailer, creates an #account_activation email, delivers it.
    UserMailer.account_activation(self).deliver_now
  end
  
  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), 
                   reset_sent_at: Time.zone.now)
  end
  
  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Selects all the microposts authored by this user.
  def feed
    Micropost.where("user_id = ?", id)
  end
  
  # Used to be private :-(
  
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # Converts email to all-lowercase.
  def downcase_email
    self.email = email.downcase
  end
  
  # Creates and assigns the activation token (N.B.!) and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
