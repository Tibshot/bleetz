t = Time.now
Gem::Specification.new do |s|
  s.name        = "bleetz"
  s.version     = "2.0"
  s.date        = t.strftime("%Y-%m-%d")
  s.summary     = "Fast KISS deployment tool"
  s.description = "Fast KISS deployment tool"
  s.authors     = ["Thibaut Deloffre"]
  s.email       = 'tib@rocknroot.org'
  s.files       = ["lib/bleetz.rb", "lib/bleetz/conf.rb", "lib/bleetz/object.rb"]
  s.executables = ["bleetz"]
  s.add_dependency "highline"
  s.add_dependency "net-ssh"
  s.extra_rdoc_files = ["LICENSE.txt"]
  s.homepage    = 'https://github.com/TibshoOT/bleetz'
  s.licenses    = ["BSD"]
end
