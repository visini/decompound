# frozen_string_literal: true

require "csv"
require "json"

module CharSplit
  # Reads the German noun CSV and turns its inflection records into words.
  class GermanNouns
    include Enumerable

    FORMS = %w[lemmas nominative all].freeze
    GERMAN_WORD = /\A[A-Za-zÄÖÜäöüẞß]+(?:-[A-Za-zÄÖÜäöüẞß]+)*\z/

    POS_HEADERS = %w[pos partofspeech wordclass wortart wortklasse wordtype type].freeze
    LEMMA_HEADERS = %w[lemma lexeme grundform].freeze
    CASE_NAMES = %w[nominativ genitiv dativ akkusativ nominative genitive dative accusative].freeze

    def initialize(path, forms: "lemmas")
      raise ArgumentError, "forms must be one of: #{FORMS.join(", ")}" unless FORMS.include?(forms)

      @path = path
      @forms = forms
    end

    def each
      return enum_for(__method__) unless block_given?

      seen = Set.new
      CSV.foreach(@path, headers: true, encoding: "bom|utf-8") do |record|
        headers = header_map(record.headers)
        next unless noun?(record, headers)
        next unless lemma_row?(record)

        selected_values(record, headers).each do |value|
          word = self.class.normalize(value)
          yield word if word && seen.add?(word)
        end
      end
    end

    def self.normalize(value)
      return unless value.is_a?(String) && value.valid_encoding?

      word = value.unicode_normalize(:nfc).strip
      word if GERMAN_WORD.match?(word)
    rescue Encoding::CompatibilityError
      nil
    end

    private

    def selected_values(record, headers)
      lemma = field(record, headers, LEMMA_HEADERS)
      return [lemma] if @forms == "lemmas"

      form_headers = record.headers.select { |header| inflection_header?(header) }
      if @forms == "nominative"
        form_headers.select! { |header| normalized_header(header).include?("nominativ") }
      end

      # A nominative singular is normally the lemma. Including it also makes
      # sparse records useful when only plural inflections have their own field.
      [lemma, *form_headers.flat_map { |header| cell_values(record[header]) }]
    end

    def cell_values(value)
      return [] unless value.is_a?(String)
      return [value] unless value.lstrip.start_with?("[")

      parsed = JSON.parse(value)
      parsed.is_a?(Array) ? parsed.select { |item| item.is_a?(String) } : []
    rescue JSON::ParserError
      []
    end

    # The source CSV lists every inflected form as its own record with empty
    # inflection cells; only records with inflection data are actual lemmas.
    def lemma_row?(record)
      record.headers.any? do |header|
        inflection_header?(header) && cell_values(record[header]).any?
      end
    end

    def noun?(record, headers)
      field(record, headers, POS_HEADERS)&.strip&.casecmp?("Substantiv")
    end

    def inflection_header?(header)
      normalized = normalized_header(header)
      CASE_NAMES.any? { |name| normalized.include?(name) }
    end

    def field(record, headers, names)
      header = names.filter_map { |name| headers[name] }.first
      record[header] if header
    end

    def header_map(headers)
      headers.compact.to_h { |header| [normalized_header(header), header] }
    end

    def normalized_header(header)
      header.to_s.unicode_normalize(:nfc).downcase.gsub(/[^a-zäöüß]/, "")
    end
  end
end
