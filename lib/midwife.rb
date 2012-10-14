require 'rake'
require 'rake/dsl_definition'
require 'midwife/helpers'
require 'midwife/tasks'

include Rake::DSL

Midwife::Tasks.build
