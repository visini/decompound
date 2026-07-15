#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "digest"
require "fileutils"
require "json"
require "net/http"
require "uri"
require "zlib"

SOURCE_URL = "https://kaikki.org/dictionary/downloads/de/de-extract.jsonl.gz"
SOURCE_SHA256 = "3d85e381c8270932c79181c09d009a259aca7534e9323783e7ccbd91c4384fc1"

ROOT = File.expand_path("..", __dir__)
ARCHIVE = File.join(ROOT, "tmp", "de-extract.jsonl.gz")
OUTPUT = File.join(ROOT, "data", "vendor", "german-nouns", "nouns.csv")

INFLECTIONS = {
  ["nominative", "singular"] => "Nominativ Singular",
  ["nominative", "plural"] => "Nominativ Plural",
  ["genitive", "singular"] => "Genitiv Singular",
  ["genitive", "plural"] => "Genitiv Plural",
  ["dative", "singular"] => "Dativ Singular",
  ["dative", "plural"] => "Dativ Plural",
  ["accusative", "singular"] => "Akkusativ Singular",
  ["accusative", "plural"] => "Akkusativ Plural"
}.freeze

CSV_HEADERS = ["Wortart", "Lemma", *INFLECTIONS.values].freeze

def download(uri, destination, redirects_left: 5)
  raise "too many redirects" if redirects_left.zero?

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request_get(uri.request_uri) do |response|
      case response
      when Net::HTTPSuccess
        File.open(destination, File::WRONLY | File::CREAT | File::EXCL) do |file|
          response.read_body { |chunk| file.write(chunk) }
        end
      when Net::HTTPRedirection
        location = URI.join(uri, response.fetch("location"))
        download(location, destination, redirects_left: redirects_left - 1)
      else
        raise "download failed: #{response.code} #{response.message}"
      end
    end
  end
end

def verify!(path)
  actual = Digest::SHA256.file(path).hexdigest
  return if actual == SOURCE_SHA256

  raise "SHA-256 mismatch for #{path}: expected #{SOURCE_SHA256}, got #{actual}"
end

FileUtils.mkdir_p(File.dirname(ARCHIVE))
unless File.exist?(ARCHIVE)
  warn "Downloading #{SOURCE_URL}"
  download(URI(SOURCE_URL), ARCHIVE)
end
verify!(ARCHIVE)

nouns = {}
Zlib::GzipReader.open(ARCHIVE) do |gzip|
  gzip.each_line do |line|
    entry = JSON.parse(line)
    lemma = entry["word"]
    next unless entry["lang_code"] == "de" && entry["pos"] == "noun"
    next unless lemma.is_a?(String) && !lemma.empty?

    inflections = nouns[lemma] ||= INFLECTIONS.values.to_h { |header| [header, Set.new] }
    Array(entry["forms"]).each do |form|
      next unless form.is_a?(Hash)

      value = form["form"]
      tags = form["tags"]
      next unless value.is_a?(String) && !value.empty? && tags.is_a?(Array)

      INFLECTIONS.each do |required_tags, header|
        inflections.fetch(header) << value if required_tags.all? { |tag| tags.include?(tag) }
      end
    end
  end
end

FileUtils.mkdir_p(File.dirname(OUTPUT))
CSV.open(OUTPUT, "wb", row_sep: "\n") do |csv|
  csv << CSV_HEADERS
  nouns.keys.sort.each do |lemma|
    inflections = nouns.fetch(lemma)
    csv << ["Substantiv", lemma, *INFLECTIONS.values.map { |header| JSON.generate(inflections.fetch(header).to_a.sort) }]
  end
end

warn "Wrote #{nouns.length} noun lemmas and their inflections to #{OUTPUT}"
