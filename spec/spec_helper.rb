require_relative "../lib/cryptopals"
require "pathname"

RSpec.configure do |config|
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end
