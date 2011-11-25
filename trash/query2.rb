require 'rubygems'
require 'sparql/client'

sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
query = sparql.select.where([:s, :p, :o]).offset(100).limit(10)
query.execute.each do |solution|
  puts solution.inspect
end