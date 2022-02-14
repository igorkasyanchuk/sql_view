class Worker < ApplicationRecord
  belongs_to :jobable, polymorphic: true
end
