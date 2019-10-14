# frozen_string_literal: true
require_relative 'file_item'

module Teneo::DataModel

  # noinspection RailsParamDefResolve
  class DirItem < FileItem

    def filename=(dir)
      raise "'#{dir}' is not a directory" unless File.directory? dir
      super
    end

  end

end
