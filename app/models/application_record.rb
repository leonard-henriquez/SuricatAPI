# Parent class for models using ActiveRecord ORM
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
