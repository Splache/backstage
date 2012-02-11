class Subscription < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :target, :class_name => 'User', :foreign_key => 'target_id'


  #*************************************************************************************
  # PUBLIC CLASS METHODS
  #*************************************************************************************
  def self.build_for_recipient(recipient_id=0)
    subscriptions = recipient_id != 0 ? self.where(:recipient_id => recipient_id).all : []

    targets = User.where("id != ?", recipient_id).all

    targets.each do |target|
      subscriptions << self.new(:recipient_id => recipient_id, :target_id => target.id) if not subscriptions.map{|s| s.target_id }.include?(target.id)
    end

    return subscriptions.sort_by{ |s| s.target.name }
  end

  def self.update_all_for_recipient(recipient_id, params)
    subscriptions = self.where(:recipient_id => recipient_id).all

    params.each do |target_id, selection|
      subscription = subscriptions.select{ |s| s.target_id == target_id.to_i }.first

      if not subscription and selection.to_i == 1
        new_subscription = self.new(:recipient_id => recipient_id, :target_id => target_id.to_i)
        new_subscription.save
      end

      subscription.destroy if subscription and selection.to_i == 0
    end
  end

  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************

end
