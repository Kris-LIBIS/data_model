# noinspection RubyStringKeysInHashInspection
require 'active_support/core_ext/hash'
require 'symbolized'

class Symbolized::SymbolizedHash

  def for(*classes)
    self.select {|_k, v| classes.include?(v[:class])}.tap {|x| puts x.inspect}
  end

  def deep_reject(&block)
    self.each_with_object({}) do |(k, v), m|
      m[k] = v.is_a?(Hash) ? v.deep_reject(&block) : v unless block.call(k, v)
    end
  end

  def deep_apply(method, &block)
    self.each_with_object({}) do |(k, v), m|
      m[k] = v.is_a?(Hash) ? v.deep_apply(method, &block) : v
    end.send(method, &block)
  end

  def transform_values(*args, &block)
    return to_enum(:transform_values) unless block_given?
    dup.tap { |hash| hash.transform_values!(*args, &block) }
  end

  def transform_keys(*args, &block)
    return to_enum(:transform_keys) unless block_given?
    dup.tap { |hash| hash.transform_keys!(*args, &block) }
  end

  def transform_keys!
    return enum_for(:transform_keys!, &method(:size)) unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end

  def slice(*keys)
    keys.map!(&method(:convert_key))
    self.class.new(super)
  end

  def slice!(*keys)
    keys.map!(&method(:convert_key))
    super
  end

  def compact
    dup.tap(&:compact!)
  end

end
