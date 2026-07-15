# frozen_string_literal: true

require "json"
require_relative "ngram_counter"

module CharSplit
  class Trainer
    def initialize(words, min_length: 3, max_length: 20)
      @words = words
      @min_length = min_length
      @max_length = max_length
    end

    def probabilities
      counter = NgramCounter.new(min_length: @min_length, max_length: @max_length)
      @words.each { |word| counter.add(word) }
      counter.probabilities
    end

    def write(path)
      File.open(path, "w:utf-8") do |file|
        JSON.dump(probabilities, file)
        file.write("\n")
      end
    end
  end
end
