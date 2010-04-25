class Collection < ActiveRecord::Base
  belongs_to :project
  has_many :tasks, :order => "name ASC", :dependent => :destroy
end