Gem::Specification.new do |s|

  s.name        = 'casa-receiver'
  s.version     = '0.0.01'
  s.summary     = 'Reference implementation of the CASA Protocol Receiver Module'
  s.authors     = ['Eric Bollens']
  s.email       = ['ebollens@ucla.edu']
  s.homepage    = 'https://appsharing.github.io/casa-protocol'
  s.license     = 'BSD-3-Clause'

  s.files       = ['lib/casa-receiver.rb']

  s.add_dependency 'rest-client'
  s.add_dependency 'thor'
  s.add_dependency 'casa-payload'
  s.add_dependency 'casa-operation-translate'

  s.add_development_dependency 'rake'

end