require 'pstore'
require 'erb'
require 'state_machine'

require 'paradeiser/errors'
require 'paradeiser/executor'
require 'paradeiser/models/scheduled'
require 'paradeiser/models/break'
require 'paradeiser/models/hook'
require 'paradeiser/models/interrupt'
require 'paradeiser/models/job'
require 'paradeiser/models/pomodoro'
require 'paradeiser/models/repository'
require 'paradeiser/models/scheduler'
require 'paradeiser/models/status'
require 'paradeiser/refinements/numeric'
require 'paradeiser/refinements/pluralize'
require 'paradeiser/router'
require 'paradeiser/version'
require 'paradeiser/view'
require 'paradeiser/controllers/controller'
require 'paradeiser/controllers/breaks_controller'
require 'paradeiser/controllers/paradeiser_controller'
require 'paradeiser/controllers/pomodori_controller'

require 'paradeiser/initializers/inflections'

module Paradeiser
  def self.par_dir
    ENV['PAR_DIR'] || File.expand_path('~/.paradeiser/')
  end

  def self.hooks_dir
    File.join(Paradeiser.par_dir, 'hooks')
  end

  def self.templates_dir
    File.join(File.dirname(__FILE__), '..', 'templates')
  end

  def self.os
    case RUBY_PLATFORM
      when /darwin/ then :mac
      when /linux/ then :linux
      else :other
    end
  end
end
