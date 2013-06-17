require "securerandom"

class BenchmarkContextWrapper
  include Garner::Cache::Context
  attr_accessor :binding, :context, :r

  def initialize(options = {})
    setup!(options)
  end

  def setup!(options)
    Monger.destroy_all
    Garner.config.cache.clear
    @binding = Monger.create!({ :name => "M1" })
    @binding.update_attributes!({
      :subdocument => SecureRandom.hex(options[:d])
    }) if options[:d]
    @r = options[:r]
    @context = BenchmarkContext.new

    # Prime MongoDB cache
    Monger.find(@binding.slug)
  end

  def warm_virtual_fetch
    warm_caches
    context.a_warm_virtual_fetch(binding.class, binding.slug, r)
  end

  def cold_virtual_fetch
    update_binding
    context.b_cold_virtual_fetch(binding.class, binding.slug, r)
  end

  def warm_class_fetch
    warm_caches
    context.c_warm_class_fetch(binding.class, binding.slug, r)
  end

  def cold_class_fetch
    update_binding
    context.d_cold_class_fetch(binding.class, binding.slug, r)
  end

  def force_invalidate
    context.e_force_invalidate(binding)
  end

  def soft_invalidate
    context.f_soft_invalidate(binding)
  end

  private
  def warm_caches
    klass, handle = binding.class, binding.slug
    json = binding.reload.to_json
    garner.bind(klass.identify(handle)).key({ :caller => nil }) { json }
    garner.bind(klass).key({ :caller => nil }) { json }
  end

  def update_binding
    # Randomly shuffle name between M1, M2, M3
    name = (["M1", "M2", "M3"] - [binding.reload.name]).sample
    binding.update_attributes!({ :name => name })
  end
end
