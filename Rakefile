include Rake::DSL
require 'rake/clean'

HAML = FileList['**/*.haml']
HTML = HAML.ext('html')
SCSS = FileList['**/*.scss']
CSS = SCSS.ext('css')

ASSETS = 'assets'
PUBLIC = 'public'

CLEAN.include HTML + CSS

desc 'Compile haml and scss'
task :care => HTML + CSS
task :default => :care

rule '.html' => '.haml' do |t|
  destination = t.name.gsub(ASSETS, PUBLIC)
  FileUtils.mkdir_p(File.dirname(destination))
  sh "haml #{t.source} #{destination}"
end

rule '.css' => '.scss' do |t|
  destination = t.name.gsub(ASSETS, PUBLIC)
  FileUtils.mkdir_p(File.dirname(destination))
  sh "sass #{t.source} #{destination}"
end
