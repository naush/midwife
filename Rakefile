include Rake::DSL
require 'rake/clean'
require 'listen'

HAML = FileList['**/*.haml']
HTML = HAML.ext('html')
SCSS = FileList['**/*.scss']
CSS = SCSS.ext('css')

ASSETS = 'assets'
PUBLIC = 'public'

CLEAN.include HTML + CSS

desc 'Care for your haml/scss'
task :care => HTML + CSS
task :default => :care

desc 'Listen to your haml/scss'
task :listen do |t|
  Listen.to(ASSETS) do |modified, added, removed|
    (modified + added).each do |source|
      extension = File.extname(source)
      if extension == '.haml'
        target = source.ext('html')
        compile('haml', source, target)
      elsif extension == '.scss'
        target = source.ext('css')
        compile('sass', source, target)
      end
    end
    removed.each do |source|
      destination = source.gsub(ASSETS, PUBLIC).ext('html')
      File.delete(destination)
    end
  end
end

rule '.html' => '.haml' do |t|
  compile("haml", t.source, t.name)
end

rule '.css' => '.scss' do |t|
  compile("sass", t.source, t.name)
end

def compile(command, source, target)
  destination = target.gsub(ASSETS, PUBLIC)
  FileUtils.mkdir_p(File.dirname(destination))
  sh "#{command} #{source} #{destination}"
end
