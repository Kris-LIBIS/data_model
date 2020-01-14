# string_literal_freeze: true

module Teneo
  module DataModel

    module StorageResolver

      protected

      def to_entry(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.entry(rel_path)
      end

      def to_dir(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.dir(rel_path)
      end

      def to_file(path)
        storage, rel_path = parse_storage_path(path)
        return nil unless storage
        storage.service&.file(rel_path)
      end

      def parse_storage_path(path)
        return nil unless path =~ /^\/\/([^:]+):(.*)/
        storage = storage_from_name($1)
        return nil unless storage
        rel_path = storage.safepath($2)
        [storage, rel_path]
      end

      def storage_from_name(name)
        return nil unless self.respond_to :organization
        org = self.organization
        return nil unless org
        org.storages.find_by(name: name)
      end

      def storage_from_purpose(purpose)
        return nil unless self.respond_to :organization
        org = self.organization
        return nil unless org
        org.storages.find_by(purpose: purpose)
      end

    end

  end
end