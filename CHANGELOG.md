## [Unreleased]

- Treat `ActiveModel::RecordNotFound` like `ActiveRecord::RecordNotFound` in `ActionDispatch`
- Properly type cast values when they are defined as attribute
- Ensure that there is always at least an empty array of records

## [0.2.0] - 2024-09-16

- Rename `ActiveModel::ModelNotFound` to `ActiveModel::RecordNotFound`
- Allow creating a `ActiveModel::Relation` without passing a collection
- Don't require a `.records` class method on model classes
- Allow passing a block to `ActiveModel::Relation#find`

## [0.1.0] - 2024-09-09

- Initial release
