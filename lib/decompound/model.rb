# frozen_string_literal: true

module Decompound
  # Reads the binary model format (decompound-binary-v1):
  #
  #   magic "DCPDv1\n"
  #   count           uint32 LE
  #   bucket_count    uint32 LE
  #   buckets         bucket_count x (key prefix, NUL-padded to 3 bytes + uint32 LE first index)
  #   offsets         (count + 1) x uint32 LE, byte offsets into the keys blob
  #   probabilities   count x 3 bytes (prefix, infix, suffix), 255 = missing
  #   keys            concatenated UTF-8 n-grams, sorted bytewise
  #
  # The file is held as a single string and searched in place, so loaded
  # memory stays near file size instead of materializing millions of Ruby
  # strings and hash entries. The buckets narrow each binary search to the
  # keys sharing the query's first three bytes.

  class Model
    MAGIC = "DCPDv1\n"
    PREFIX = 0
    INFIX = 1
    SUFFIX = 2
    MISSING = 255
    SCALE = 254.0

    def self.load(path)
      new(File.binread(path))
    end

    def initialize(data)
      raise ArgumentError, "not a decompound binary model" unless data.byteslice(0, MAGIC.bytesize) == MAGIC

      @data = data.freeze
      @count, bucket_count = data.byteslice(MAGIC.bytesize, 8).unpack("VV")
      buckets_at = MAGIC.bytesize + 8
      @offsets_at = buckets_at + (bucket_count * 7)
      @probabilities_at = @offsets_at + ((@count + 1) * 4)
      @keys_at = @probabilities_at + (@count * 3)
      @buckets = read_buckets(data, buckets_at, bucket_count)
    end

    def probability(ngram, position, default)
      index = find(ngram.b)
      return default unless index

      code = @data.getbyte(@probabilities_at + (index * 3) + position)
      (code == MISSING) ? default : code / SCALE
    end

    private

    def read_buckets(data, buckets_at, bucket_count)
      firsts = bucket_count.times.map { |i| data.byteslice(buckets_at + (i * 7) + 3, 4).unpack1("V") }
      firsts << @count
      buckets = {}
      bucket_count.times do |i|
        buckets[data.byteslice(buckets_at + (i * 7), 3)] = [firsts[i], firsts[i + 1] - 1]
      end
      buckets.freeze
    end

    def find(query)
      low, high = @buckets[query.byteslice(0, 3).ljust(3, "\0")]
      return nil unless low

      while low <= high
        mid = (low + high) / 2
        from, upto = @data.byteslice(@offsets_at + (mid * 4), 8).unpack("VV")
        case query <=> @data.byteslice(@keys_at + from, upto - from)
        when 0 then return mid
        when -1 then high = mid - 1
        else low = mid + 1
        end
      end
      nil
    end
  end
end
