# ActiveModel::Relation

Query a collection of ActiveModel objects like an ActiveRecord::Relation.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add active_model-relation

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install active_model-relation

## Usage

### Initialization

Create a new relation by passing the model class and a collection:

```ruby
relation = ActiveModel::Relation.new(Project, [
  Project.new(id: 1, state: 'draft', priority: 1),
  Project.new(id: 2, state: 'running', priority: 2),
  Project.new(id: 3, state: 'completed', priority: 3),
  Project.new(id: 4, state: 'completed', priority: 1)
])
```

As an alternative, it's also possible to create a collection for a model without explicitly passing a collection.
In this case, the library will attempt to call `Project.records` to get the default collection. If the method doesn't exist or returns `nil`, the collection will default to an empty array.

```ruby
class Project
  def self.records
    [
      Project.new(id: 1, state: 'draft', priority: 1),
      Project.new(id: 2, state: 'running', priority: 2),
      Project.new(id: 3, state: 'completed', priority: 3),
      Project.new(id: 4, state: 'completed', priority: 1)
    ]
  end
end

relation = ActiveModel::Relation.new(Project)
```

### Querying

An `ActiveModel::Relation` can be queried almost exactly like an `ActiveRecord::Relation`.

#### `#find`

You can look up a record by it's primary key, using the `find` method. If no record is found, it will raise a `ActiveModel::Relation::RecordNotFound` error.

```ruby
project = relation.find(1)
```

By default, `ActiveModel::Relation` will assume `:id` as the primary key. You can customize this behavior by setting a `primary_key` on the model class.

```ruby
class Project
  def self.primary_key = :identifier
end
```

When passed a block, the `find` method will behave like `Enumerable#find`.

```ruby
project = relation.find { |p| p.id == 1 }
```

#### `#find_by`

To look up a record based on a set of arbitary attributes, you can use `find_by`. It accepts the same arguments as `#where` and will return the first matching record.

```ruby
project = relation.find_by(state: 'draft')
```

#### `#where`

To filter a relation, you can use `where` and pass a set of attributes and the expected values. This method will return a new `ActiveModel::Relation` that only returns the matching records, so it's possible to chain multiple calls. The filtering will only happen when actually accessing records.

```ruby
relation.where(state: 'completed')
```

The following two lines will return the same filtered results:

```ruby
relation.where(state: 'completed', priority: 1)
relation.where(state: 'completed').where(priority: 1)
```

To allow for more advanced filtering, `#where` allows filtering using a block. This works similar to `Enumerable#select`, but will return a new `ActiveModel::Relation` instead of an already filtered array.

```ruby
relation.where { |p| p.state == 'completed' && p.priority == 1 }
```

#### `#where.not`

Similar to `#where`, the `#where.not` chain allows you to filter a relation. It will also return a new `ActiveModel::Relation` with that returns only the matching records.

```ruby
relation.where.not(state: 'draft')
```

To allow for more advanced filtering, `#where.not` allows filtering using a block. This works similar to `Enumerable#reject`, but will return a new `ActiveModel::Relation` instead of an already filtered array.

```ruby
relation.where.not { |p| p.state == 'draft' && p.priority == 1 }
```

### Sorting

It is possible to sort an `ActiveModel::Relation` by a given set of attribute names. Sorting will be applied after filtering, but before limits and offsets.

#### `#order`

To sort by a single attribute in ascending order, you can just pass the attribute name to the `order` method.

```ruby
relation.order(:priority)
```

To specify the sort direction, you can pass a hash with the attribute name as key and either `:asc`, or `:desc` as value.

```ruby
relation.order(priorty: :desc)
```

To order by multiple attributes, you can pass them in the order of specificity you want.

```ruby
relation.order(:state, :priority)
```

For multiple attributes, it's also possible to specify the direction.

```ruby
relation.order(state: :desc, priority: :asc)
```

### Limiting and offsets

#### `#limit`

To limit the amount of records returned in the collection, you can call `limit` on the relation. It will return a new `ActiveModel::Relation` that only returns the given limit of records, allowing you to chain multiple other calls. The limit will only be applied when actually accessing the records later on.

```ruby
relation.limit(10)
```

#### `#offset`

To skip a certain number of records in the collection, you can use `offset` on the relation. It will return a new `ActiveModel::Relation` that skips the given number of records at the beginning. The offset will only be applied when actually accessing the records later on.

```ruby
relation.offset(20)
```

### Scopes

After including `ActiveModel::Relation::Model`, the library also supports calling class methods defined on the model class as part of the relation.

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

Given the example above, you can now create relations like you're used to from `ActiveRecord::Relation`.

```ruby
projects = Project.all
completed_projects = all_projects.completed
important_projects = all_projects.where(priority: 1)
```

### Spawning

It's possilbe to create new versions of a `ActiveModel::Relation` that only includes certain aspects of the `ActiveModel::Relation` it is based on. It's currently possible to customize the following aspects: `:where`, `:limit`, `:offset`.

#### `#except`

To create a new `ActiveModel::Relation` without certain aspects, you can use `except` and pass a list of aspects, you'd like to exclude from the newly created instance. The following example will create a new `ActiveModel::Relation` without any previously defined limit or offset.

```ruby
relation.except(:limit, :offset)
```
#### `#only`

Similar to `except`, the `only` method will return a new instance of the `ActiveModel::Relation` it is based on but with only the passed list of aspects applied to it.

```ruby
relation.only(:where)
```

### Extending relations

#### `#extending`

In order to add additional methods to a relation, you can use `extending`. You can either pass a list of modules that will be included in this particular instance, or a block defining additional methods.

```ruby
module Pagination
  def page_size = 25

  def page(page)
    limit(page_size).offset(page.to_i * page_size)
  end

  def total_count
    except(:limit, :offset).count
  end
end

relation.extending(Pagination)
```

The following example is equivalent to the example above:

```ruby
relation.extending do
  def page_size = 25

  def page(page)
    limit(page_size).offset(page.to_i * page_size)
  end

  def total_count
    except(:limit, :offset).count
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
