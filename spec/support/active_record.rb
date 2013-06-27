require "active_record"
require "garner/mixins/active_record"

# Set up in-memory SQLite connection for ActiveRecord
ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:"
})

# Include mixin
module ActiveRecord
  class ActiveRecord::Base
    include Garner::Mixins::ActiveRecord::Base
  end
end

# Stub classes
ActiveRecord::Migration.verbose = false
ActiveRecord::Migration.create_table :activists do |t|
  t.string :name
  t.timestamps
end

class Activist < ActiveRecord::Base
end

# Wrap each test example in a failing transaction to ensure a clean
# database for each run.
RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
