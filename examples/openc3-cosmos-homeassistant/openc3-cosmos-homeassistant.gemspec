# encoding: ascii-8bit

spec = Gem::Specification.new do |s|
  s.name = 'openc3-cosmos-homeassistant'
  s.summary = 'OpenC3 COSMOS Home Assistant Integration'
  s.description = <<-EOF
    Example plugin providing a microservice that communicates with Home Assistant using the Python homeassistant package.
  EOF
  s.licenses = ['AGPL-3.0-only', 'Nonstandard']
  s.authors = ['OpenC3']
  s.email = ['support@openc3.com']
  s.homepage = 'https://github.com/OpenC3/cosmos'
  s.platform = Gem::Platform::RUBY

  if ENV['VERSION']
    s.version = ENV['VERSION'].dup
  else
    time = Time.now.strftime("%Y%m%d%H%M%S")
    s.version = '0.0.0' + ".#{time}"
  end
  s.files = Dir.glob("{targets,lib,tools,microservices}/**/*") + %w(Rakefile README.md LICENSE.txt plugin.txt)
end
