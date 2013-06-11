# Set up in-memory SQLite connection for ActiveRecord
ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:"
})

# Stub classes
ActiveRecord::Migration.create_table :activists do |t|
  t.string :name
  t.timestamps
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
