# -*- encoding : utf-8 -*-
require 'sinatra/base'
require 'multi_json'
require 'sinatra/json'
require 'mime-types'
require 'hashie'
require 'logger'
require 'rest-client'
require 'aliexpress/version'
require 'aliexpress/web'
require 'aliexpress/profile'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/conversions'

module Aliexpress
  autoload :Configure, File.expand_path('../aliexpress/configure', __FILE__)
  autoload :Base, File.expand_path('../aliexpress/base', __FILE__)

  class << self
    include Configure
  end
end

Gem.find_files('aliexpress/*.rb').each { |path| require path }