require "spec_helper"
require "method_profiler"

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "support/benchmark_context"
require "support/benchmark_context_proxy"

class StrategyBenchmark
  attr_accessor :n, :d

  def initialize(options = {})
    @n = options[:n] || 1000   # Number of iterations
    @d = options[:d] || 1024   # Document payload size
  end

  def run!
    profiler = MethodProfiler.observe(BenchmarkContext)
    self.class.strategy_pairs.each do |key_strategy, invalidation_strategy|
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
        config.binding_key_strategy = key_strategy
        config.binding_invalidation_strategy = invalidation_strategy
      end

      proxy = BenchmarkContextProxy.new({ :d => d })

      # Workaround for MethodProfiler bug
      profiler.instance_variable_set(:@data, Hash.new { |h, k| h[k] = [] })
      n.times do
        # Randomize order of calls
        [
          :warm_virtual_fetch,
          :cold_virtual_fetch,
          :warm_class_fetch,
          :cold_class_fetch,
          :force_invalidate,
          :soft_invalidate
        ].shuffle.each { |method| proxy.send(method) }
      end

      puts "Key: #{key_strategy.to_s.split("::")[-1]}"
      puts "Invalidation: #{invalidation_strategy.to_s.split("::")[-1]}"
      puts profiler.report.sort_by(:method).order(:ascending)
      puts "\n\n"
    end
  end

  private
  def self.strategy_pairs
    {
      Garner::Strategies::Binding::Key::Base =>
        Garner::Strategies::Binding::Invalidation::Base,
      Garner::Strategies::Binding::Key::SafeCacheKey =>
        Garner::Strategies::Binding::Invalidation::Touch
    }
  end

end
