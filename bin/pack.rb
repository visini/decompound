#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts the trained JSON probability tables into the binary runtime model
# shipped with the gem:
#
#   ruby bin/pack.rb [data/ngram_probs.json] [data/model.bin]

require "json"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "decompound/packer"

root = File.expand_path("..", __dir__)
input = ARGV.fetch(0, File.join(root, "data/ngram_probs.json"))
output = ARGV.fetch(1, File.join(root, "data/model.bin"))

probabilities = JSON.parse(File.read(input, encoding: "utf-8"))
File.binwrite(output, Decompound::Packer.new.pack(probabilities))
puts "#{output}: #{File.size(output)} bytes"
