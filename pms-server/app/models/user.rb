class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:user_name]

  scoped_search on: :name

  def ensure_autnehtication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def email_required?
    false
  end

  def role_name
    roles.collect{|role| role.name}
  end

  def av?
    user.has_role? :av
  end

  def admin?
    user.has_role? :av
  end

  def cutting?
    user.has_role? :cutting
  end

  private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
