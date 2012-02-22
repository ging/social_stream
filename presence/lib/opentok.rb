$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010, TokBox, Inc.

 Last modified: 2011-02-17
=end


require 'rubygems'
require 'net/http'
require 'uri'
require 'digest/md5'
require 'cgi'
#require 'pp' # just for debugging purposes

Net::HTTP.version_1_2 # to make sure version 1.2 is used

module OpenTok
  VERSION = "tbrb-v0.91.2011-02-17"
  API_URL = "https://api.opentok.com/hl";
end

require 'OpenTok/Exceptions'
require 'OpenTok/OpenTokSDK'
