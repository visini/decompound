# frozen_string_literal: true

require_relative "decompound/version"

module Decompound
  def self.split(word)
    # Naive implementation: split the word in the middle. Just a placeholder :)
    word = word.downcase
    middle = word.length / 2

    [word[0...middle], word[middle..]]
  end
end
