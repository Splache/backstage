class Project < ActiveRecord::Base
	has_many :code_files, :order => "path ASC, name ASC", :dependent => :destroy
	has_many :collections, :order => "name ASC", :dependent => :destroy
	has_many :documents, :order => "path ASC, name ASC", :dependent => :destroy
  has_many :tasks, :order => "name ASC", :dependent => :destroy


  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************
  def code_files_tree
	  tree = self.code_files

	  tree = tree.sort_by{|f| f.full_path}

	  return tree
  end
end
