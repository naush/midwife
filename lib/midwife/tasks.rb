require 'haml'
require 'listen'
require 'sass'

module Midwife
  class Tasks
    HAML = FileList['**/*.haml']
    HTML = HAML.ext('html')
    SCSS = FileList['**/*.scss']
    CSS = SCSS.ext('css')

    ASSETS = 'assets'
    PUBLIC = 'public'
    CONFIG = "config.ru"
    GEMFILE = "Gemfile"

    class << self
      def build
        desc 'Setup your environment'
        task :setup do
          setup
        end

        desc 'Care for your haml/scss'
        task :care => HTML + CSS

        desc 'Listen to your haml/scss'
        task :listen do
          listen
        end

        desc 'Serve your haml/scss'
        task :serve do
          serve
        end

        rule '.html' => '.haml' do |t|
          render(:haml, t.source, t.name)
        end

        rule '.css' => '.scss' do |t|
          render(:scss, t.source, t.name)
        end
      end

      def render(syntax, source, target)
        return if source.split("/").last.match(/^\_/)

        source_dir = File.dirname(source)
        destination = target.gsub(ASSETS, PUBLIC)
        FileUtils.mkdir_p(File.dirname(destination))
        template = File.read(source)

        if syntax == :haml
          output = Haml::Engine.new(template).render(Helpers.new(source_dir))
        elsif syntax == :scss
          output = Sass::Engine.new(template, :syntax => syntax).render
        end

        File.open(destination, 'w') do |file|
          file.write(output)
        end

        puts "#{syntax}: convert #{source} to #{destination}."
      rescue Exception => e
        puts "#{syntax}: failed to convert #{source} to #{destination}."
        puts e.message
        puts e.backtrace.first
      end

      def setup
        FileUtils.mkdir_p(ASSETS) unless File.exists?(ASSETS)
        FileUtils.mkdir_p(PUBLIC) unless File.exists?(PUBLIC)

        current_dir = File.expand_path(File.dirname(__FILE__))

        FileUtils.cp("#{current_dir}/templates/#{CONFIG}", CONFIG) unless File.exists?(CONFIG)
        FileUtils.cp("#{current_dir}/templates/#{GEMFILE}", GEMFILE) unless File.exists?(GEMFILE)
      end

      def listen
        trap (:SIGINT) { exit }

        Listen.to(ASSETS) do |modified, added, removed|
          (modified + added).each do |source|
            extension = File.extname(source)

            if extension == '.haml'
              target = source.ext('html')
              render(:haml, source, target)
            elsif extension == '.scss'
              target = source.ext('css')
              render(:scss, source, target)
            end
          end

          removed.each do |source|
            extension = File.extname(source)
            if extension == '.haml'
              destination = source.gsub(ASSETS, PUBLIC).ext('html')
            elsif extension == '.scss'
              destination = source.gsub(ASSETS, PUBLIC).ext('css')
            end
            File.delete(destination)
          end
        end
      end

      def serve
        fork { listen }
        `rackup`
      end
    end
  end
end
