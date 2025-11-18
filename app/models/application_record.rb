#NOTE: Models represent your data and business logic, backed by ActiveRecord ORM
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
