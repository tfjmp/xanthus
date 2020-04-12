#coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xanthus/version"

Gem::Specification.new do |spec|
  spec.name          = "xanthus"
  spec.version       = Xanthus::VERSION
  spec.authors       = ['Thomas Pasquier', 'Xueyuan "Michael" Han']
  spec.email         = ["thomas.pasquier@bristol.ac.uk"]

  spec.summary       = %q{Automated intrusion detection dataset generation framework.}
  spec.description   = %q{Automated intrusion detection dataset generation framework.}
  spec.homepage      = "http://camflow.org"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  spec.bindir        = "bin"
  spec.executables   = ["xanthus"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
