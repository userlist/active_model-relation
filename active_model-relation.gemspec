# frozen_string_literal: true

require_relative 'lib/active_model/relation/version'

Gem::Specification.new do |spec|
  spec.name = 'active_model-relation'
  spec.version = ActiveModel::Relation::VERSION
  spec.authors = ['Benedikt Deicke']
  spec.email = ['benedikt@benediktdeicke.com']

  spec.summary = 'Query collection of ActiveModel objects like an ActiveRecord::Relation'
  spec.description = 'This library allows querying of collections of Ruby objects, with a similar interface ' \
                     'to ActiveRecord::Relation.'
  spec.homepage = 'https://github.com/benedikt/active_model-relation/'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/benedikt/active_model-relation/'
  spec.metadata['changelog_uri'] = 'https://github.com/benedikt/active_model-relation/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '~> 7.2'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
