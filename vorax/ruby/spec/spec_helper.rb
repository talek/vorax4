# encoding: UTF-8

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

# Initialize the VORAX_TEST_CSTR environment variable with
# the user/pwd@db connection string, pointing to VORAX test
# user, or change the below line accordingly.
VORAX_CSTR = "connect #{ENV['VORAX_TEST_CSTR']}"

require 'tempfile'
require 'timeout'
require 'vorax'

