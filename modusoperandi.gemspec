require 'rubygems'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "modusoperandi"
    s.version   =   "1.0.2"
    s.author    =   "Simon Ordish"
    s.email     =   "simon.ordish@lvs.co.uk"
    s.summary   =   "A utility to manage configuration files"
    s.files     =   Dir['bin/mo*']
    s.require_path  =   "bin"
    s.default_executable = %q{mo2}
    s.executables = %w(mo mo.bat mo2 mo2.bat)
end
