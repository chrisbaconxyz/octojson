testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)

libdir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

require "rubygems"
require "octojson"
require "minitest/autorun"
require "minitest/unit"
require "pry"

Dir[File.join(__dir__, 'fixtures', 'models', '*.rb')].each { |file| require file }

dbconfig = YAML.load(File.open(File.join(__dir__,'db','config.yml')))
ActiveRecord::Base.establish_connection(dbconfig["test"])
