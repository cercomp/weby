# Compatibility for the Weby Paperclip fork, which still calls URI.escape and
# URI.unescape removed from Ruby's public URI API in Ruby 3.
# Remove this shim after replacing/updating that fork.
require 'uri'

module URI
  def self.escape(string, unsafe = nil)
    unsafe ? DEFAULT_PARSER.escape(string, unsafe) : DEFAULT_PARSER.escape(string)
  end unless respond_to?(:escape)

  def self.unescape(string, escaped = nil)
    escaped ? DEFAULT_PARSER.unescape(string, escaped) : DEFAULT_PARSER.unescape(string)
  end unless respond_to?(:unescape)
end
