# string_literal_freeze: true

module Teneo
  module DataModel

    module StorageResolver

      protected

      # convert storage path to Entry object
      # @param [String] path
      # @return [Teneo::DataModel::StorageDriver::Base::Entry]
      def to_entry(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.entry(rel_path)
      end

      # convert storage path to Dir object
      # @param [String] path
      # @return [Teneo::DataModel::StorageDriver::Base::Dir]
      def to_dir(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.dir(rel_path)
      end

      # convert storage path to File object
      # @param [String] path
      # @return [Teneo::DataModel::StorageDriver::Base::File]
      def to_file(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.file(rel_path)
      end

      # parse storage path into storage driver and relative path
      # @param [String] path
      # @return [Array<Teneo::DataModel::StorageDriver::Base or String>]
      def parse_storage_path(path)
        return nil unless path =~ /^\/\/([^:]+):(.*)/
        storage = storage_from_name($1)
        return nil unless storage
        rel_path = storage.safepath($2)
        [storage, rel_path]
      end

      # convert storage name to storage driver
      # @param [String] name
      # @return [Teneo::DataModel::StorageDriver::Base]
      def storage_from_name(name)
        return nil unless self.respond_to :organization
        org = self.organization
        return nil unless org
        org.storages.find_by(name: name)
      end

      # convert storage purpose to storage driver
      # @param [String] purpose
      # @return [Teneo::DataModel::StorageDraiver::Base]
      def storage_from_purpose(purpose)
        return nil unless self.respond_to :organization
        org = self.organization
        return nil unless org
        org.storages.find_by(purpose: purpose)
      end

    end

  end
end