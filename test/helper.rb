$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'lib/at_mock'
require 'paradeiser'
include Paradeiser

require_relative 'lib/unit_test'
require_relative 'lib/assertions'
require_relative 'lib/at_mock'
require_relative 'lib/controller_test'
require_relative 'lib/integration_test'
require_relative 'lib/options_mock'
require_relative 'lib/paradeiser_controller_test'
require_relative 'lib/process_status_mock'
require_relative 'lib/pstore_mock'
require_relative 'lib/schedulable_mock'
require_relative 'lib/token_file_registry'
require_relative 'lib/view_test'
