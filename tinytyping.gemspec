# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tinytyping/version'

Gem::Specification.new do |spec|
  spec.name          = 'tinytyping'
  spec.version       = TinyTyping::VERSION
  spec.authors       = ['ofk']
  spec.email         = ['ofkjpn+github@gmail.com']

  spec.summary       = 'tinytyping is simply type check.'
  spec.description   = 'tinytyping is simply type check.'
  spec.homepage      = 'https://github.com/ofk/tinytyping'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rubocop'
end
