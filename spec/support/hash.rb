# noinspection RubyStringKeysInHashInspection
require 'active_support/core_ext/hash'

class Hash

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

end