# frozen_string_literal: true

require "test_helper"
require "decompound/packer"

class TestModel < Minitest::Test
  PROBABILITIES = {
    "prefix" => {"ein" => 0.75, "grüß" => 1.0, "ei" => 0.5},
    "infix" => {"kauf" => 0.0625},
    "suffix" => {"liste" => 0.25, "kauf" => 0.125}
  }.freeze

  def setup
    @model = Decompound::Model.new(Decompound::Packer.new.pack(PROBABILITIES))
  end

  def test_round_trips_probabilities_within_quantization_error
    PROBABILITIES.each_with_index do |(_, table), position|
      table.each do |ngram, probability|
        assert_in_delta probability, @model.probability(ngram, position, nil), 0.5 / 254, ngram
      end
    end
  end

  def test_returns_default_for_missing_position_of_known_ngram
    assert_equal(-1, @model.probability("liste", Decompound::Model::PREFIX, -1))
    assert_equal 1, @model.probability("ein", Decompound::Model::INFIX, 1)
  end

  def test_returns_default_for_unknown_ngram
    assert_equal(-1, @model.probability("zzz", Decompound::Model::PREFIX, -1))
  end

  def test_rejects_data_without_magic
    assert_raises(ArgumentError) { Decompound::Model.new("not a model") }
  end
end
