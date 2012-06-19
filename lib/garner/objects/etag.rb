module Garner
  module Objects
    module ETag
      class << self
        # @abstract
        # Serialize in a way such that the ETag matches that which would 
        # be returned by Rack::ETag at response time.
        def from(object)
          serialization = case object
            when nil then ""
            when String then object
            when Hash then object.respond_to?(:to_json) ? object.to_json : MultiJson.dump(object)
            else Marshal.dump(object)
          end
          %("#{Digest::MD5.hexdigest(serialization)}")
        end
      end
    end
  end
end
