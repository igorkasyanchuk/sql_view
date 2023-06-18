class Account < ApplicationRecord
  has_many :users

  has_one :account_stat_view, class_name: AccountStatViewView.model.to_s, foreign_key: :account_id
  has_many :active_users, join_table: :active_users_views, class_name: ActiveUserView.model.to_s, foreign_key: :account_id
end
