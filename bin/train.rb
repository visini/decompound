#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "optparse"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "charsplit/german_nouns"
require "charsplit/trainer"

root = File.expand_path("..", __dir__)
options = {
  input: File.join(root, "data/vendor/german-nouns/nouns.csv"),
  output: File.join(root, "data/ngram_probs.json"),
  forms: "all"
}

parser = OptionParser.new do |arguments|
  arguments.banner = "Usage: ruby bin/train.rb [options]"
  arguments.on("--input PATH", "German nouns CSV") { |path| options[:input] = path }
  arguments.on("--forms MODE", CharSplit::GermanNouns::FORMS, "lemmas, nominative, or all") do |mode|
    options[:forms] = mode
  end
  arguments.on("--output PATH", "Output JSON path") { |path| options[:output] = path }
  arguments.on("-h", "--help", "Show this help") do
    puts arguments
    exit
  end
end

begin
  parser.parse!
  raise OptionParser::InvalidArgument, "unexpected arguments: #{ARGV.join(" ")}" unless ARGV.empty?

  nouns = CharSplit::GermanNouns.new(options.fetch(:input), forms: options.fetch(:forms))
  FileUtils.mkdir_p(File.dirname(options.fetch(:output)))
  CharSplit::Trainer.new(nouns).write(options.fetch(:output))
rescue OptionParser::ParseError => error
  warn error.message
  warn parser
  exit 1
end
