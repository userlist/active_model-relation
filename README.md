# ActiveModel::Relation

A library that allows querying of collections of Ruby objects, with a similar interface to `ActiveRecord::Relation`.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add active_model-relation

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install active_model-relation

## Usage

Create a new relation by passing the model class and a collection:

```ruby
relation = ActiveModel::Relation.new(Project, [
  Project.new(id: 1, state: 'draft', priority: 1),
  Project.new(id: 2, state: 'running', priority: 2),
  Project.new(id: 3, state: 'completed', priority: 3),
  Project.new(id: 4, state: 'completed', priority: 1)
])
```

Afterwards you can use it (almost) like an `ActiveRecord::Relation`.

```ruby
relation.where(state: 'completed')
relation.offset(3)
relation.limit(2)
relation.order(priority: :asc, state: :desc)
```

You can also write named filter methods on the model class, after including `ActiveModel::Relation::Model`.

```ruby
class Project
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Relation::Model

  attribute :id, :integer
  attribute :state, :string, default: :draft
  attribute :priority, :integer, default: 1

  def self.completed
    where(state: 'completed')
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/userlist/active_model-relation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/userlist/active_model-relation/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveModel::Relation project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/userlist/active_model-relation/blob/main/CODE_OF_CONDUCT.md).
