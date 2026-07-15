# frozen_string_literal: true

require "json"
require_relative "decompound/version"

module Decompound
  NGRAM_PATH = File.expand_path("../data/ngram_probs.json", __dir__)
  FUGEN_S_ENDINGS = %w[ts gs ks hls ns].freeze

  def self.split(word)
    word = word.downcase

    if word.include?("-")
      left, separator, right = word.rpartition("-")
      return [left, right] unless separator.empty?
    end

    best = split_candidates(word).max_by { |score, left, right| [score, left, right] }
    best ? best.drop(1) : [word, word]
  end

  def self.split_candidates(word)
    probabilities = ngram_probabilities

    (3...(word.length - 2)).map do |position|
      left = word[0...position]
      right = word[position..]
      left_ngram = without_fugen_s(left)
      right_ngram = without_fugen_s(right)

      suffix_probability = probabilities.fetch("suffix").fetch(left_ngram, -1)
      prefix_probability = probabilities.fetch("prefix").fetch(right_ngram, -1)
      infix_probability = (3..(word.length + 1)).filter_map do |length|
        ngram = right[0, length]
        probabilities.fetch("infix").fetch(ngram, 1) unless ngram.empty?
      end.min

      [prefix_probability - infix_probability + suffix_probability, left, right]
    end
  end
  private_class_method :split_candidates

  def self.without_fugen_s(ngram)
    return ngram unless FUGEN_S_ENDINGS.any? { |ending| ngram.end_with?(ending) }
    return ngram unless ngram.length - 1 > 2

    ngram[0...-1]
  end
  private_class_method :without_fugen_s

  def self.ngram_probabilities
    @ngram_probabilities ||= JSON.parse(File.read(NGRAM_PATH, encoding: "utf-8"))
  end
  private_class_method :ngram_probabilities
end
