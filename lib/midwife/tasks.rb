require 'haml'
require 'listen'
require 'sass'
require 'uglifier'
require 'chunky_png'
require 'ostruct'

module Midwife
  class Tasks
    ASSETS = 'assets'
    PUBLIC = 'public'
    CONFIG = "config.ru"
    GEMFILE = "Gemfile"

    HAML = FileList[ASSETS + '/**/*.haml']
    SCSS = FileList[ASSETS + '/**/*.scss']
    JS   = FileList[ASSETS + '/**/*.js']
    PNG  = FileList[ASSETS + '/**/*.png']

    EXT_SYNTAX = {
      '.haml' => { :ext => 'html', :syntax => :haml },
      '.scss' => { :ext => 'css', :syntax => :scss },
      '.js'   => { :ext => 'js', :syntax => :js }
    }

    class << self
      def build
        desc 'Care for your haml, scss, and js'
        task(:care) { care }

        desc 'Listen to your haml, scss, and js'
        task(:listen) { listen }

        desc 'Setup your environment'
        task(:setup) { setup }

        desc 'Serve your haml, scss and js'
        task(:serve) { serve }

        desc 'Stitch your png'
        task(:stitch) { stitch }
      end

      def render(source)
        return if source.split("/").last.match(/^\_/)

        extension = File.extname(source)
        ext_syntax = EXT_SYNTAX[extension]
        syntax = ext_syntax[:syntax]
        destination = source.ext(ext_syntax[:ext]).gsub(ASSETS, PUBLIC)
        source_dir = File.dirname(source)
        FileUtils.mkdir_p(File.dirname(destination))

        helpers = Helpers.new(source_dir)
        template = File.read(source)
        output = case syntax
                 when :haml; Haml::Engine.new(template, {:format => :html5, :ugly => true}).render(helpers)
                 when :scss; Sass::Engine.new(template, {:syntax => syntax, :style => :compressed, :load_paths => [source_dir]}).render
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
        FileUtils.mkdir_p(ASSETS + '/images') unless File.exists?(ASSETS + '/images')
        FileUtils.mkdir_p(ASSETS + '/stylesheets') unless File.exists?(ASSETS + '/stylesheets')
        FileUtils.mkdir_p(PUBLIC + '/images') unless File.exists?(PUBLIC + '/images')
        FileUtils.mkdir_p(PUBLIC + '/stylesheets') unless File.exists?(PUBLIC + '/images')

        current_dir = File.expand_path(File.dirname(__FILE__))

        FileUtils.cp("#{current_dir}/templates/#{CONFIG}", CONFIG) unless File.exists?(CONFIG)
        FileUtils.cp("#{current_dir}/templates/#{GEMFILE}", GEMFILE) unless File.exists?(GEMFILE)
      end

      def serve
        fork { listen }
        `rackup`
      end

      def stitch
        offset_height = 0

        sprites = PNG.collect do |file|
          image = ChunkyPNG::Image.from_file(file)
          sprite = OpenStruct.new
          sprite.name = File.basename(file, '.png')
          sprite.image = image
          sprite.min_width = 0
          sprite.max_width = image.width
          sprite.min_height = offset_height
          sprite.max_height = offset_height + image.height
          offset_height = sprite.max_height
          sprite
        end

        max_width = sprites.collect(&:max_width).max
        max_height = sprites.last.max_height
        target = ChunkyPNG::Image.new(max_width, max_height, ChunkyPNG::Color::TRANSPARENT)

        css = ''
        sprites.each do |sprite|
          css = css + '.' + sprite.name + "-image { background:url(../images/application.png) 0 #{-1 * sprite.min_height}px; }\n"
          target.compose!(sprite.image, 0, sprite.min_height)
          puts "png: stitch #{sprite.name} to application.png"
        end

        File.open(ASSETS + '/stylesheets/_sprites.scss', 'w') do |file|
          puts "scss: create assets/stylesheets/_sprites.scss"
          file.write(css)
        end

        target.save(PUBLIC + '/images/application.png')
      end
    end
  end
end
