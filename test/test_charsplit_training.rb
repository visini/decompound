# frozen_string_literal: true

require "tempfile"
require "test_helper"
require "charsplit/german_nouns"
require "charsplit/ngram_counter"

class TestCharsplitTraining < Minitest::Test
  def test_reads_normalized_unique_noun_lemmas
    csv = Tempfile.new(["nouns", ".csv"])
    csv.write(<<~CSV)
      Wortart,Lemma,Nominativ Singular,Genitiv Singular
      Substantiv,A\u0308hre,Ähren,Ähre
      Verb,Laufen,Laufen,Laufens
      Substantiv,Ähre,Ähren,Ähre
      Substantiv,Haus 2,Häuser 2,Hauses 2
      Substantiv,Öl-Fass,Öl-Fässer,Öl-Fasses
      Substantiv,Ähren,,
    CSV
    csv.close

    nouns = CharSplit::GermanNouns.new(csv.path)

    assert_equal ["Ähre", "Öl-Fass"], nouns.to_a
  ensure
    csv&.unlink
  end

  def test_selects_requested_inflections
    csv = Tempfile.new(["nouns", ".csv"])
    csv.write(<<~CSV)
      Wortart,Lemma,Nominativ Plural,Genitiv Singular
      Substantiv,Fahrrad,"[""Fahrräder"",""Fahrrade""]","[""Fahrrades""]"
    CSV
    csv.close

    assert_equal ["Fahrrad", "Fahrräder", "Fahrrade"], CharSplit::GermanNouns.new(csv.path, forms: "nominative").to_a
    assert_equal ["Fahrrad", "Fahrräder", "Fahrrade", "Fahrrades"], CharSplit::GermanNouns.new(csv.path, forms: "all").to_a
  ensure
    csv&.unlink
  end

  def test_matches_charsplits_short_word_overcounting
    counter = CharSplit::NgramCounter.new
    2.times { counter.add("Haus") }

    probabilities = counter.probabilities
    assert_equal 1.0, probabilities.fetch("prefix").fetch("hau")
    assert_equal 0.5, probabilities.fetch("prefix").fetch("haus")
    assert_equal 1.0, probabilities.fetch("suffix").fetch("aus")
    assert_empty probabilities.fetch("infix")
  end
end
