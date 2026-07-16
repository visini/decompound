# frozen_string_literal: true

require_relative "decompound/version"
require_relative "decompound/model"

module Decompound
  MODEL_PATH = File.expand_path("../data/model.bin", __dir__)
  FUGEN_S_ENDINGS = %w[ts gs ks hls ns].freeze

  # Loads the model up front instead of on the first split. Called by Rails
  # on boot when config.eager_load is enabled (see Decompound::Railtie).
  def self.eager_load!
    model
    nil
  end

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
    model = self.model

    (3...(word.length - 2)).map do |position|
      left = word[0...position]
      right = word[position..]
      left_ngram = without_fugen_s(left)
      right_ngram = without_fugen_s(right)

      suffix_probability = model.probability(left_ngram, Model::SUFFIX, -1)
      prefix_probability = model.probability(right_ngram, Model::PREFIX, -1)
      # CharSplit scans lengths up to word.length + 1; slices past the end of
      # +right+ all yield +right+ itself, so stopping there is equivalent.
      infix_probability = (3..right.length).map do |length|
        model.probability(right[0, length], Model::INFIX, 1)
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

  def self.model
    @model ||= Model.load(MODEL_PATH)
  end
  private_class_method :model
end

require_relative "decompound/railtie" if defined?(Rails::Railtie)
