class User < ActiveRecord::Base
  before_save { self.email = email.downcase } # downcases email before saving so case-sensitive indexers don't break
  validates :name,  presence: true,  length: { maximum: 50 } # auto-validation, very cool
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i   # used to check that input email is hip to the groove
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }    # since emails must be unique, checks before saving
end
