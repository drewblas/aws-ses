%w[ base64 cgi openssl digest/sha1 net/https net/http rexml/document time ostruct mail].each { |f| require f }

begin
  require 'URI' unless defined? URI
rescue Exception => e
  # nothing
end

begin
  require 'xmlsimple' unless defined? XmlSimple
rescue Exception => e
  require 'xml-simple' unless defined? XmlSimple
end

$:.unshift(File.dirname(__FILE__))
require 'ses/extensions'

require 'ses/response'
require 'ses/send_email'
require 'ses/info'
require 'ses/base'
require 'ses/version'
require 'ses/addresses'