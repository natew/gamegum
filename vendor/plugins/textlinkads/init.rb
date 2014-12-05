# Copyright 2006 Pascal Belloncle

require 'textlinkads'

ActionController::Base.send :include, Textlinkads
ActionController::Base.send :helper, TextlinkadsHelper
