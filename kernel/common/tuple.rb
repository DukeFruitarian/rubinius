# -*- encoding: us-ascii -*-

##
# The tuple data type.
# A simple storage class. Created to contain a fixed number of elements.
#
# Not designed to be subclassed, as it does not call initialize
# on new instances.

module Rubinius
  class Tuple

    include Enumerable

    def self.[](*args)
      start = args.start
      tot = args.size
      return new(tot).copy_from(args.tuple, start, tot, 0)
    end

    def to_s
      "#<#{self.class}:0x#{object_id.to_s(16)} #{fields} elements>"
    end

    def each
      (0...fields).each do |i|
        yield at(i)
      end

      self
    end

    def ==(tup)
      return super unless tup.kind_of?(Tuple)

      t = fields

      return false unless t == tup.size

      (0...t).each do |i|
        return false unless at(i) == tup.at(i)
      end

      true
    end

    def +(o)
      t = Tuple.new(size + o.size)
      t.copy_from(self, 0, size, 0)
      t.copy_from(o, 0, o.size, size)
      t
    end

    def inspect
      str = "#<#{self.class}"

      str << (fields.zero? ? " empty>" : ": #{join(", ", :inspect)}>")
    end

    def join(sep, meth=:to_s)
      join_upto(sep, fields, meth)
    end

    def join_upto(sep, count, meth=:to_s)
      return "" if count.zero? or empty?

      count = fields if count > fields

      (0...count).inject("") do |str, i|
        str << at(i).__send__(meth)
        str << sep.dup if i < count - 1
        str
      end
    end

    def ===(other)
      return false unless Tuple === other and fields == other.fields
      (0...fields).each do |i|
        return false unless at(i) === other.at(i)
      end
      true
    end

    def to_a
      ary = Array.allocate
      ary.tuple = dup
      ary.total = fields
      ary
    end

    def shift
      return self unless fields > 0
      t = Tuple.new(fields-1)
      t.copy_from self, 1, fields-1, 0
      t
    end

    # Swap elements of the two indexes.
    def swap(a, b)
      at(a), at(b) = at(b), at(a)
    end

    alias_method :size, :fields
    alias_method :length, :fields

    def empty?
      size == 0
    end

    def first
      at(0)
    end

    def last
      at(fields - 1)
    end

    # Marshal support - _dump / _load are deprecated so eventually we should figure
    # out a better way.
    def _dump(depth)
      # TODO use depth
      Marshal.dump to_a
    end

    def self._load(str)
      ary = Marshal.load(str)
      t = new(ary.size)
      ary.each_with_index { |obj, idx| t[idx] = obj }
      return t
    end
  end
end
