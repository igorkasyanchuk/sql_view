# Rails + SQL View

[!["Buy Me A Coffee"](https://github.com/igorkasyanchuk/get-smart/blob/main/docs/snapshot-bmc-button-small.png?raw=true)](https://buymeacoffee.com/igorkasyanchuk)

## The easist way to add and work with SQL view in your app.

If you are lazy and don't like to write SQL to create SQL view but you know AR use your skills to create views.

Production-ready.

![Demo](docs/sql_view.gif?raw=true "Demo")

## Usage

The most simple way to add a view is to call a generator (examples below):

```bash
rails g sql_view:view DeletedProjects 'Project.only_deleted'
rails g sql_view:view ActiveUsers 'User.confirmed.where(active: true)' --materialized
```

Depending on whether you need a materialized view or not add `--materialized` flag (later you can change in "view" class). Materialized views works in Postgres.

Generator will create a file similar to:

```ruby
class ActiveUserView < SQLView::Model
  materialized

  schema -> { User.where(age: 18..60) }

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
```

or if you want to use SQL to create a regular view:


```ruby
class ActiveUserView < SQLView::Model
  schema -> { "SELECT * FROM users WHERE active = TRUE" }
end
```

or the same but materialized:

```ruby
class ActiveUserView < SQLView::Model
  materialized
  schema -> { "SELECT * FROM users WHERE active = TRUE" }
end
```

Later with view you can work same way as with any model(ActiveRecord class). For example:

```ruby
ActiveUserView.model.count
# or
ActiveUserView.count
# ----
ActiveUserView.find(42)
# you can apply scopes, relations, methods, BUT add them in extend_model_with block

ActiveUserView.model.by_role("admin").count
ActiveUserView.where(role: "admin").exists?
ActiveUserView.model.includes(:profile)
```

If you need to refresh materialized view - `ActiveUserView.sql_view.refresh` (if you need to do it concerrently - `.refresh(concurrently: false)`.

It can also be used with your other models:

```ruby
class Account < ApplicationRecord
  has_many :users

  has_one :account_stat_view, class_name: AccountStatViewView.model.to_s, foreign_key: :account_id
  has_many :active_users, join_table: :active_users_views, class_name: ActiveUserView.model.to_s, foreign_key: :account_id
end
```


More examples in this file: `./test/sql_view_test.rb`

## Installation

```ruby
gem "sql_view"
```

And then execute:
```bash
$ bundle
```

And use generator. Or you can connect it to existing view with `view_name=`:

```ruby
class OldUserView < SqlView::Model
  self.view_name = "all_old_users"

  materialized

  schema -> {  User.where("age > 18") }

  extend_model_with do
    scope :ordered, -> { order(:id) }

    def test_instance_method
      42
    end
  end
end
```

## Materialized view + concurrent update

1. add index

```ruby
  add_index SomeView.view_name, :user_id, unique: true
```

2. refresh with parameter

```ruby
  SomeView.sql_view.refresh(concurrently: true)
```

3. profit :)

## TODO

- CI with different versions of Rails/Ruby
- make unit tests works with `rake test`
- `cascade` option
- move classes to own files
- code coverage
- verify how it works with other DB's
- check if schema was changed on migrate or schema dump?

## Testing

`ruby ./test/sql_view_test.rb` (because somehow `rake test` not works, not critical for now)

## Contributing

You are welcome to contribute.

## Credits

I know about and actually using `gem scenic`, which is very nice and I tool some examples from it how to dump view into schema.rb but this gem was created to simplify life and reduce amount of time needed to write SQL to create a sql view.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[<img src="https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/more_gems.png?raw=true"
/>](https://www.railsjazz.com/?utm_source=github&utm_medium=bottom&utm_campaign=sql_view)

[!["Buy Me A Coffee"](https://github.com/igorkasyanchuk/get-smart/blob/main/docs/snapshot-bmc-button.png?raw=true)](https://buymeacoffee.com/igorkasyanchuk)
