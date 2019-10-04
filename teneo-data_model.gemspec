# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teneo/data_model/version'

Gem::Specification.new do |spec|
  spec.name          = 'teneo-data_model'
  spec.version       = ::Teneo::DataModel::VERSION
  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']

  spec.summary       = %q{Teneo Data Model gem.}
  spec.description   = %q{This gem bundles the low-level data model and its logic for re-use in different parts of the application.}
  spec.homepage      = 'http://teneo.libis.be.'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://gihub.com/Kris-LIBIS/TeneoDataModel'
    spec.metadata['changelog_uri'] = 'https://gihub.com/Kris-LIBIS/TeneoDataModel/changes.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'awesome_print', '~> 1.8'
  spec.add_development_dependency 'tty-prompt'
  spec.add_development_dependency 'tty-spinner'
  spec.add_development_dependency 'pry'

  spec.add_runtime_dependency 'activerecord', '> 5.2'
  spec.add_runtime_dependency 'activesupport', '> 5.2'
  # spec.add_runtime_dependency 'reform', '~> 2.2.4'
  # # spec.add_runtime_dependency 'trailblazer', '~> 2.1.0.rc1'
  # spec.add_runtime_dependency 'trailblazer', '~> 2.0'
  # spec.add_runtime_dependency 'dry-validation', '~> 0.13'
  # spec.add_runtime_dependency 'symbolized'
  spec.add_runtime_dependency 'acts_as_list'
  spec.add_runtime_dependency 'order_as_specified'
  spec.add_runtime_dependency 'globalid'

  spec.add_runtime_dependency 'pg'
end
