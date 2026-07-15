# frozen_string_literal: true

require "test_helper"

class TestDecompound < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Decompound::VERSION
  end

  def test_splits_correctly
    File.foreach(File.join(__dir__, "fixtures", "words.tsv"), chomp: true) do |line|
      compound, expected = line.split("\t", 2)

      assert_equal expected.split("|"), Decompound.split(compound), compound
    end
  end

  def test_splits_with_known_failures
    File.foreach(File.join(__dir__, "fixtures", "failures.tsv"), chomp: true) do |line|
      compound, expected, known_failure = line.split("\t", 3)
      result = Decompound.split(compound)

      refute_equal expected.split("|"), result, "#{compound} no longer fails; remove it from failures.tsv"
      assert_equal known_failure.split("|"), result, "#{compound} should eventually split as #{expected}"
    end
  end
end
