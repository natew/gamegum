# Copyright 2006 Pascal Belloncle
def __DIR__; File.dirname(__FILE__); end

#Rails.root = File.join(File.dirname(__FILE__), '..')
$:.unshift(__DIR__ + '/../lib')
begin
  require 'rubygems'
rescue LoadError
  $:.unshift(__DIR__ + '/../../../activerecord/lib')
  $:.unshift(__DIR__ + '/../../../activesupport/lib')
  $:.unshift(__DIR__ + '/../../../actionpack/lib/')
end

Rails.env = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))


require 'test/unit'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'
require 'action_controller/benchmarking'
require 'breakpoint'
require 'benchmark'

class ActionController::Base; def rescue_action(e) raise e end; end

class TextlinkadsTest < Test::Unit::TestCase
  include Textlinkads
  include ActionController::TestProcess
  include ActionController
#  include ActionController::Base
#  include ActionController::Caching
#  include ActionController::Caching::Fragments
#  include ActionController::Benchmarking
#  include ActionController::Benchmarking::ClassMethods
#  include Benchmark
    
  def setup
    @request = ActionController::TestRequest.new
    @request.env['REQUEST_URI'] = "http://localhost"
    @request.env['HTTP_USER_AGENT'] = "TestUA"
    TLA_CONFIG['caching'] = false
    TLA_CONFIG['testing'] = true
  end

  def test_render_TLA
    #use test URL
    assert_equal "http://localhost", @request.env['REQUEST_URI']
    assert_equal "TestUA", @request.env['HTTP_USER_AGENT']
    assert_equal "<div id=\"textlinkads\"><h3>Sponsors</h3><ul><li>Get <a href=\"http://www.text-link-ads.com\">Text Link Ads</a> Now!</li><li>Todays <a href=\"http://www.text-link-ads.com/Business-C30/\">Business Text Link Ads</a> Now</li></ul></div>", render_TLA()
  end
  
  def test_no_links_message
    # get a non existent set of links to trigger "Advertise here message"
    TLA_CONFIG['key'] = "no key"
    TLA_CONFIG['testing'] = false
    assert_equal "<div id=\"textlinkads\"><h3>Sponsors</h3><ul><a href=\"http://www.text-link-ads.com/?ref=11111\">Advertise here!</a></ul></div>", render_TLA()
    TLA_CONFIG['affiliateid'] = 0
    assert_equal "<div id=\"textlinkads\"><h3>Sponsors</h3><ul><a href=\"http://www.text-link-ads.com/\">Advertise here!</a></ul></div>", render_TLA()
  end
    
  def test_links_TLA
    links = links_TLA()
    assert_not_nil links
    assert_equal "Text Link Ads", links['Link'][0]['Text'][0]
    assert_equal "http://www.text-link-ads.com", links['Link'][0]['URL'][0]
    assert_equal "Get", links['Link'][0]['BeforeText'][0]
    assert_equal "Now!", links['Link'][0]['AfterText'][0]
  end
  
end
