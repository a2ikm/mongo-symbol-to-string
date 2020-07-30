# Usage: ruby test.rb

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

  gem "mongo"
  gem "test-unit"
end

require "test/unit/assertions"
include Test::Unit::Assertions

logger = Logger.new($stderr)
logger.level = Logger::INFO

client = Mongo::Client.new("mongodb://mongo/test", logger: logger)

collection = client["test"]
collection.find.delete_many

collection.insert_one({ name: "John Smith", sex: :male })
collection.insert_one({ name: "Jane Doe",   sex: "female" })

doc1 = collection.find(name: "John Smith").first
assert_equal :male, doc1["sex"]

collection.aggregate([
  {
    :$set => {
      sex: {
        :$convert => {
          input:   "$sex",
          to:      "string",
          onError: "",
        }
      }
    }
  }
]).to_a

doc2 = collection.find(name: "John Smith").first
assert_equal "male", doc1["sex"]
