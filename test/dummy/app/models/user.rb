class User < ApplicationRecord
  belongs_to :account, optional: true
end
