# frozen_string_literal: true

namespace :import do
  desc "Diagnostic : affiche structure ODS (10 premières lignes par onglet)"
  task inspect: :environment do
    file_path = Import::Orchestrator::PRODUCTS_FILE
    puts "=== Inspection de #{file_path} ==="

    spreadsheet = Import::OdsReader.call(file_path)

    spreadsheet.sheets.each do |sheet_name|
      puts "\n#{'=' * 60}"
      puts "ONGLET: #{sheet_name} (#{spreadsheet.sheet(sheet_name).last_row || 0} lignes)"
      puts '=' * 60

      sheet = spreadsheet.sheet(sheet_name)
      next unless sheet.last_row

      (1..[sheet.last_row, 15].min).each do |row|
        cells = (1..([sheet.last_column, 30].min)).map { |col| sheet.cell(row, col) }
        puts "  Ligne #{row}: #{cells.inspect}"
      end
    end
  end

  desc "Diagnostic : affiche structure du fichier Recettes ODS"
  task inspect_recipes: :environment do
    file_path = Import::Orchestrator::RECIPES_FILE
    puts "=== Inspection de #{file_path} ==="

    spreadsheet = Import::OdsReader.call(file_path)

    spreadsheet.sheets.each do |sheet_name|
      puts "\n#{'=' * 60}"
      puts "ONGLET: #{sheet_name} (#{spreadsheet.sheet(sheet_name).last_row || 0} lignes)"
      puts '=' * 60

      sheet = spreadsheet.sheet(sheet_name)
      next unless sheet.last_row

      (1..[sheet.last_row, 20].min).each do |row|
        cells = (1..([sheet.last_column, 15].min)).map { |col| sheet.cell(row, col) }
        puts "  Ligne #{row}: #{cells.inspect}"
      end
    end
  end

  desc "Import produits : purge + fournisseurs + produits + génère mapping CSV"
  task products: :environment do
    Import::Orchestrator.import_products!
  end

  desc "Import recettes (après validation humaine du CSV de mapping)"
  task recipes: :environment do
    Import::Orchestrator.import_recipes!
  end

  desc "Import complet (produits + recettes, si mapping déjà validé)"
  task all: :environment do
    Import::Orchestrator.import_all!
  end
end
