module Garner
  module Strategies
    module Context
      module Key
        class Caller < Base

          def self.field
            :caller
          end

          # Determine the most likely root path for the current Garner client
          # application. If in a Rails application, Rails.root is used.
          # Otherwise, the nearest ancestor directory containing a Gemfile is
          # used.
          #
          # @see Garner::Config#caller_root=
          # @see Garner::Config#default_caller_root
          # @return [String] The default root path.
          def self.default_root
            if defined?(::Rails) && ::Rails.respond_to?(:root)
              ::Rails.root.realpath.to_s
            else
              # Try to use the nearest ancestor directory containing a Gemfile.
              requiring_caller = send(:caller).detect do |line|
                !line.include?(File.join("lib", "garner"))
              end
              return nil unless requiring_caller

              requiring_file = requiring_caller.split(":")[0]
              gemfile_root(File.dirname(requiring_file))
            end
          end

          # Injects the caller's location into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Object] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def self.apply(identity, ruby_context = nil)
            value = nil

            if ruby_context.send(:caller)
              ruby_context.send(:caller).compact.each do |line|
                parts = line.match(/(?<filename>[^:]+)\:(?<lineno>[^:]+)/)
                file = (Pathname.new(parts[:filename]).realpath.to_s rescue nil)
                next if file.nil? || file == ""
                next if file.include?(File.join("lib", "garner"))

                if (root = Garner.config.caller_root)
                  root += File::SEPARATOR unless root[-1] == File::SEPARATOR
                  next unless file =~ /^#{root}/
                  value = "#{file.gsub(root || "", "")}:#{parts[:lineno]}"
                else
                  value = "#{file}:#{parts[:lineno]}"
                end

                break
              end
            end

            value ? identity.key(field => value) : identity
          end

          private
          def self.gemfile_root(path)
            path = Pathname.new(path).realpath.to_s
            newpath = Pathname.new(File.join(path, "..")).realpath.to_s
            if newpath == path
              # We've reached the filesystem root; return
              return nil
            elsif File.exist?(File.join(newpath, "Gemfile"))
              # We've struck Gemfile gold; return current path
              return newpath
            else
              return gemfile_root(newpath)
            end
          end

        end
      end
    end
  end
end
