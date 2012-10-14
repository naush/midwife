module Midwife
  class Helpers
    def initialize(current)
      @current = current
    end

    def render(partial)
      partial_file = "#{@current}/_#{partial}.haml"
      template = File.read(partial_file)
      output = Haml::Engine.new(template).render(Helpers.new(@current))
      puts "haml: convert #{partial_file}."
      return output
    rescue Exception => e
      puts "haml: failed to convert #{partial_file}."
      puts e.message
      puts e.backtrace.first
    end
  end
end
