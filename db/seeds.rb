require 'teneo/data_model'

dir = File.join __dir__, 'seeds'
Teneo::DataModel::SeedLoader.new(dir)
