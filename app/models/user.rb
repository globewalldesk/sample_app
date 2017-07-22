class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save { email.downcase! } # downcases email before saving so case-sensitive indexers don't break
  validates :name,  presence: true,  length: { maximum: 50 } # auto-validation, very cool
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i   # used to check that input email is hip to the groove
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }    # since emails must be unique, checks before saving
  has_secure_password
  validates :password, length: { minimum: 6 }
  validates :password, format: { with: /[a-z]/ }
  validates :password, format: { with: /[A-Z]/ }
  validates :password, format: { with: /\d/ }
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token. Note, this is a class method; doesn't depend on any particular user.
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Remembers a user in the database for use in persistent sessions.
  # This is used in sessions_controller.rb via sessions_helper.rb.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil? # Helps the user log out.
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # Forgets a user.
  def forget
    # Deletes the remember digest from the database.
    # That could explain why this is here rather than in sessions_helper.rb,
    # where it is used.
    update_attribute(:remember_digest, nil)
  end
end
