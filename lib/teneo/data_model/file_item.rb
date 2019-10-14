# frozen_string_literal: true
require_relative 'item'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class FileItem < Item

    include Libis::Workflow::FileItem

    def filename=(file)
      raise "'#{file}' is not a file" unless File.file? file
      super
    end

  end

end
