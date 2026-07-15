# frozen_string_literal: true

module CharSplit
  # Counts where character n-grams occur in a collection of words.
  class NgramCounter
    POSITIONS = %i[prefix infix suffix].freeze

    def initialize(min_length: 3, max_length: 20)
      @min_length = min_length
      @max_length = max_length
      @positional_counts = POSITIONS.to_h { |position| [position, Hash.new(0)] }
      @total_counts = Hash.new(0)
    end

    def add(word)
      characters = word.downcase.chars
      middle = characters[1...-1] || []

      (@min_length..@max_length).each do |length|
        # This deliberately retains CharSplit's behavior for words shorter than
        # +length+: Python's slices return the complete word in that case.
        count(:prefix, characters.first(length).join)
        count(:suffix, characters.last(length).join)

        middle.each_cons(length) { |ngram| count(:infix, ngram.join) }
      end

      self
    end

    def probabilities
      POSITIONS.to_h do |position|
        probabilities = @positional_counts.fetch(position).each_with_object({}) do |(ngram, count), result|
          result[ngram] = count.fdiv(@total_counts.fetch(ngram)) if count > 1
        end
        [position.to_s, probabilities]
      end
    end

    private

    def count(position, ngram)
      return if ngram.empty?

      @positional_counts.fetch(position)[ngram] += 1
      @total_counts[ngram] += 1
    end
  end
end
