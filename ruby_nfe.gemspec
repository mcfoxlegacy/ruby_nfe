# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_nfe/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby_nfe"
  gem.version       = RubyNfe::VERSION
  gem.authors       = ["Softpagina"]
  gem.email         = ["suporte@softpagina.com.br"]
  gem.description   = %q{Montar uma visualização da NFe}
  gem.summary       = %q{Monta uma visualização da NFe}
  gem.homepage      = ""

  gem.files         = Dir["{lib/**/*.rb,lib/**/*.haml,README.rdoc,spec/**/*.rb,Rakefile,*.gemspec,lib/locales/*.yml,lib/*.css}"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('haml')
  gem.add_dependency('nokogiri')
  gem.add_dependency('i18n')
  gem.add_dependency('actionpack')
end