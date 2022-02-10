class ActiveAccountView < SqlView::Model
  schema -> { Account.where(active: true) }
end