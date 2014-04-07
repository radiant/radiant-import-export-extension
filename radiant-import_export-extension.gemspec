# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'import_export/version'

Gem::Specification.new do |gem|
  gem.name          = "radiant-import_export-extension"
  gem.version       = ImportExport::VERSION
  gem.authors       = ["Sean Cribbs","Johannes Fahrenkrug","Drew Neil","Istvan Hoka","Chris Parrish","Andrew vonderLuft"]
  gem.email         = ["avonderluft@avlux.net"]
  gem.description   = %q{Enhanced version of exporting and importing your Radiant database tables to/from YAML files}
  gem.summary       = %q{Supports more flexible import and export to Radiant databases.}
  gem.homepage      = "https://github.com/radiant/radiant-import-export-extension"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end