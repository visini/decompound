# frozen_string_literal: true

require "test_helper"

class TestDecompound < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Decompound::VERSION
  end

  def test_splits_words_in_the_middle
    File.foreach(File.join(__dir__, "fixtures", "words.tsv"), chomp: true) do |line|
      compound, expected = line.split("\t", 2)

      assert_equal expected.split("|"), Decompound.split(compound)
    end
  end
end
