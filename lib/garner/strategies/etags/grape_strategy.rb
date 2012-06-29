module Garner
  module Strategies
    module ETags
      module Grape
        class << self
          # @abstract
          # Serialize in a way such that the ETag matches that which would
          # be returned by Grape + Rack::ETag at response time.
          def apply(object)
            serialization = encode_json(object || "")
            %("#{Digest::MD5.hexdigest(serialization)}")
          end

          # See https://github.com/intridea/grape/blob/master/lib/grape/middleware/base.rb
          def encode_json(object)
            return object if object.is_a?(String)

            if object.respond_to? :serializable_hash
              MultiJson.dump(object.serializable_hash)
            elsif object.kind_of?(Array) && !object.map {|o| o.respond_to? :serializable_hash }.include?(false)
              MultiJson.dump(object.map {|o| o.serializable_hash })
            elsif object.respond_to? :to_json
              object.to_json
            else
              MultiJson.dump(object)
            end
          end
        end
      end
    end
  end
end
