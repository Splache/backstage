require 'digest/sha1'

class User < ActiveRecord::Base
	has_many :assignments, :class_name => 'Task', :foreign_key => 'assigned_to'
	has_many :tasks, :class_name => 'Task', :foreign_key => 'created_by'
  
	validates_presence_of :email, :first_name, :last_name, :login
	validates_presence_of :password, :if => :password_required?
	validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
	validates_uniqueness_of :email, :login
	validates_length_of :login, :within => 5..12	
	validates_length_of :password, :within => 6..12, :if => :password_required?
	validates_confirmation_of :password, :if => :password_required?
	
	attr_accessor :password, :password_confirmation
  attr_accessible :email, :first_name, :last_name, :login, :password

  
  #*************************************************************************************
  # ACCESSORS
  #*************************************************************************************
  def name
    first_name + ' ' + last_name
  end
  
  def password=(pass)
    @password = pass
    if !@password.blank?
      self.salt = Tools::Babel.random_string(10) if !self.salt?
      self.hashed_password = User.encrypted_password(@password, self.salt)
    end
  end
	
	
	#*************************************************************************************
  # CLASS METHODS
  #*************************************************************************************
  def self.authenticate(login, password)
    user = first(:conditions => {:login => login})
    
    if user
      return user.id if User.encrypted_password(password, user.salt) == user.hashed_password
    end
    
    return nil
  end
  
  def self.authenticate_with_remember_me_key(key)
    user_id = key.split(':')[0]
    hash = key.split(':')[1]
    
    user = first(:conditions => {:id => user_id})
    if user
      timestamp = user.created_at.to_i.to_s
      return user.id if hash == encrypted_cookie(timestamp)
    end
    
    return nil
  end
  
  def self.generate_remember_me_key(user_id)
    user = first(:conditions => {:id => user_id})
    timestamp = user.created_at.to_i.to_s
    hash = encrypted_cookie(timestamp)
    
    return "#{user_id}:#{hash}"
  end
  
  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  
  
  #*************************************************************************************
  # PROTECTED METHODS
  #*************************************************************************************
	protected
  
  def self.encrypted_cookie(timestamp)
	  return Digest::SHA1.hexdigest(timestamp + 'asKgjhFLhjhKJHgkGy5765gjy56tD5kFhM')
  end
  
	def self.encrypted_password(pass, salt)
		return Digest::SHA1.hexdigest(pass + salt)
	end
	
	def password_required?
    return (!self.id or !password.blank?)
	end
end