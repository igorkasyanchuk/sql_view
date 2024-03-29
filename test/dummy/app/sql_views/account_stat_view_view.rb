class AccountStatViewView < SQLView::Model

  schema -> {
    "SELECT accounts.id as account_id, RANDOM() as factor from accounts"
  }

  extend_model_with do
    # sample how you can extend it, similar to regular AR model
    #
    # include SomeConcern
    #
    # belongs_to :user
    # has_many :posts
    #
    # scope :ordered, -> { order(:created_at) }
    # scope :by_role, ->(role) { where(role: role) }
  end
end
