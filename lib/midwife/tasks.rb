require 'listen'

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

    CLEAN.include HTML + CSS

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
          compile("haml", t.source, t.name)
        end

        rule '.css' => '.scss' do |t|
          compile("sass", t.source, t.name)
        end
      end

      def compile(command, source, target)
        destination = target.gsub(ASSETS, PUBLIC)
        FileUtils.mkdir_p(File.dirname(destination))
        sh "#{command} #{source} #{destination}"
      end

      def setup
        FileUtils.mkdir_p(ASSETS) unless File.exists?(ASSETS)
        FileUtils.mkdir_p(PUBLIC) unless File.exists?(PUBLIC)

        current_dir = File.expand_path(File.dirname(__FILE__))

        FileUtils.cp("#{current_dir}/templates/#{CONFIG}", CONFIG) unless File.exists?(CONFIG)
        FileUtils.cp("#{current_dir}/templates/#{GEMFILE}", GEMFILE) unless File.exists?(GEMFILE)
      end

      def listen
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

      def serve
        trap('SIGINT') {}
        fork { listen }
        `rackup`
      end
    end
  end
end
