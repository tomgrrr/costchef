# frozen_string_literal: true

module Import
  class OdsReader
    def self.call(file_path)
      new(file_path).call
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def call
      validate_file!
      Roo::Spreadsheet.open(@file_path)
    end

    private

    def validate_file!
      raise ArgumentError, "Fichier introuvable : #{@file_path}" unless File.exist?(@file_path)
    end
  end
end
