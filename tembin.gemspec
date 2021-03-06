# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tembin/version'

Gem::Specification.new do |spec|
  spec.name          = "tembin"
  spec.version       = Tembin::VERSION
  spec.authors       = ["Takatoshi Maeda"]
  spec.email         = ["me@tmd.tw"]

  spec.summary       = %q{Codenized Re:dash configurations}
  spec.homepage      = "https://github.com/TakatoshiMaeda/tembin"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "diffy"
  spec.add_runtime_dependency "highline"
  spec.add_runtime_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5.0"
  spec.add_development_dependency "pry"
end
