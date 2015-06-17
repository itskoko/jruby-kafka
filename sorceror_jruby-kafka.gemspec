Gem::Specification.new do |spec|
  spec.name          = File.basename(__FILE__, '.gemspec')
  spec.version       = '2.0.0'
  spec.authors       = ['Kareem Kouddous']
  spec.email         = ['kareemknyc@gmail.com']
  spec.description   = 'Ruby wrapper around java kafka high-level consumer'
  spec.summary       = 'jruby Kafka wrapper'
  spec.homepage      = 'https://github.com/itskoko/jruby-kafka'
  spec.license       = 'Apache 2.0'
  spec.platform      = 'java'
  spec.require_paths = [ 'lib' ]

  spec.files = Dir[ 'lib/**/*.rb', 'lib/**/*.jar', 'lib/**/*.xml' ]

  #Jar dependencies
  spec.requirements << "jar 'org.apache.kafka:kafka_2.10', '0.8.2.1'"
  spec.requirements << "jar 'org.slf4j:slf4j-log4j12', '1.7.10'"

  # Gem dependencies
  spec.add_runtime_dependency 'jar-dependencies', '~> 0'
  spec.add_runtime_dependency 'ruby-maven', '~> 3.1'

  spec.add_development_dependency 'rake', '~> 10.4'
end
