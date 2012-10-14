require 'haml'
require 'listen'
require 'sass'
require 'uglifier'

module Midwife
  class Tasks
    ASSETS = 'assets'
    PUBLIC = 'public'
    CONFIG = "config.ru"
    GEMFILE = "Gemfile"

    HAML = FileList[ASSETS + '/**/*.haml']
    SCSS = FileList[ASSETS + '/**/*.scss']
    JS   = FileList[ASSETS + '/**/*.js']

    EXT_SYNTAX = {
      '.haml' => { :ext => 'html', :syntax => :haml },
      '.scss' => { :ext => 'css', :syntax => :scss },
      '.js'   => { :ext => 'js', :syntax => :js }
    }

    class << self
      def build
        desc 'Care for your haml/scss/js'
        task(:care) { care }

        desc 'Listen to your haml/scss/js'
        task(:listen) { listen }

        desc 'Setup your environment'
        task(:setup) { setup }

        desc 'Serve your haml/scss/js'
        task(:serve) { serve }
      end

      def render(source)
        return if source.split("/").last.match(/^\_/)

        extension = File.extname(source)
        ext_syntax = EXT_SYNTAX[extension]
        syntax = ext_syntax[:syntax]
        destination = source.ext(ext_syntax[:ext]).gsub(ASSETS, PUBLIC)
        FileUtils.mkdir_p(File.dirname(destination))

        helpers = Helpers.new(File.dirname(source))
        template = File.read(source)
        output = case syntax
                 when :haml; Haml::Engine.new(template, {:format => :html5, :ugly => true}).render(helpers)
                 when :scss; Sass::Engine.new(template, {:syntax => syntax, :style => :compressed}).render
                 when :js; Uglifier.compile(template)
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

      def care
        (HAML + SCSS + JS).each do |source|
          render(source)
        end
      end

      def listen
        trap (:SIGINT) { exit }

        Listen.to(ASSETS) do |modified, added, removed|
          (modified + added).each do |source|
            render(source)
          end

          removed.each do |source|
            extension = File.extname(source)
            destination = case extension
                          when '.haml'; source.gsub(ASSETS, PUBLIC).ext('html')
                          when '.scss'; source.gsub(ASSETS, PUBLIC).ext('css')
                          when '.js'; source.gsub(ASSETS, PUBLIC)
                          end
            File.delete(destination)
          end
        end
      end

      def setup
        FileUtils.mkdir_p(ASSETS) unless File.exists?(ASSETS)
        FileUtils.mkdir_p(PUBLIC) unless File.exists?(PUBLIC)

        current_dir = File.expand_path(File.dirname(__FILE__))

        FileUtils.cp("#{current_dir}/templates/#{CONFIG}", CONFIG) unless File.exists?(CONFIG)
        FileUtils.cp("#{current_dir}/templates/#{GEMFILE}", GEMFILE) unless File.exists?(GEMFILE)
      end

      def serve
        fork { listen }
        `rackup`
      end
    end
  end
end
