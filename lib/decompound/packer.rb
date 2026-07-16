# frozen_string_literal: true

require_relative "model"

module Decompound
  # Compiles the trained JSON probability tables into the binary runtime model, see Decompound::Model

  class Packer
    POSITIONS = {"prefix" => Model::PREFIX, "infix" => Model::INFIX, "suffix" => Model::SUFFIX}.freeze

    def pack(probabilities)
      entries = Hash.new { |hash, key| hash[key] = [Model::MISSING] * 3 }
      POSITIONS.each do |position, slot|
        probabilities.fetch(position).each do |ngram, probability|
          entries[ngram.b][slot] = (probability.clamp(0.0, 1.0) * Model::SCALE).round
        end
      end

      keys = entries.keys.sort!
      offsets = []
      blob = +""
      buckets = +""
      bucket_count = 0
      previous_prefix = nil
      keys.each_with_index do |key, index|
        prefix = key.byteslice(0, 3).ljust(3, "\0")
        if prefix != previous_prefix
          buckets << prefix << [index].pack("V")
          bucket_count += 1
          previous_prefix = prefix
        end
        offsets << blob.bytesize
        blob << key
      end
      offsets << blob.bytesize

      Model::MAGIC.b +
        [keys.length, bucket_count].pack("VV") +
        buckets +
        offsets.pack("V*") +
        keys.flat_map { |key| entries.fetch(key) }.pack("C*") +
        blob
    end
  end
end
