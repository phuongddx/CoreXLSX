//
//  RingSizeEntry.swift
//  CoreXLSX
//
//  Created by Phuong Doan Duy on 26/4/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import CoreXLSX

struct RingSizeEntry {
  var sizes: [String: String] // Country -> Size
}

class RingSizeConverter {
  var sizeTable: [RingSizeEntry] = []
  var countries: [String] = []
  
  init(filePath: String) throws {
    let file = XLSXFile(filepath: filePath)!
    guard let sharedStrings = try file.parseSharedStrings() else {
      throw NSError(domain: "No shared strings found", code: 1)
    }
    
    for wbk in try file.parseWorkbooks() {
      for sheet in try file.parseWorksheetPathsAndNames(workbook: wbk) {
        let ws = try file.parseWorksheet(at: sheet.path)
        guard let rows = ws.data?.rows else { continue }
        
        // First row = headers
        let headers = rows[0].cells.compactMap { $0.stringValue(sharedStrings) }
        countries = headers
        
        for row in rows.dropFirst() {
          var sizeMap: [String: String] = [:]
          for (i, cell) in row.cells.enumerated() {
            if i < headers.count {
              let country = headers[i]
              let value = cell.stringValue(sharedStrings) ?? ""
              sizeMap[country] = value
            }
          }
          sizeTable.append(RingSizeEntry(sizes: sizeMap))
        }
        print("Size Table: ", sizeTable.count)
      }
    }
  }

  func printSizeTable() {
    print("📏 Ring Size Table:")
    print(countries.joined(separator: " | "))
    for entry in sizeTable {
      // Kiểm tra nếu mọi giá trị đều rỗng hoặc chỉ chứa khoảng trắng
      let values = countries.map { entry.sizes[$0]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
      let isEmptyRow = values.allSatisfy { $0.isEmpty }
      
      if !isEmptyRow {
        let row = values.map { $0.isEmpty ? "-" : $0 }.joined(separator: " | ")
        print(row)
      }
    }
  }
  
  func convert(size: String, from fromCountry: String = "Mexico", to toCountry: String = "UK") -> String? {
    for entry in sizeTable {
      if let match = entry.sizes[fromCountry], match == size {
        return entry.sizes[toCountry]
      }
    }
    return nil
  }

  func getSizes(for country: String) -> [String] {
    guard countries.contains(country) else {
      print("❗️Country '\(country)' not found in header.")
      return []
    }
    var results: [String] = []
    for entry in sizeTable {
      if let value = entry.sizes[country]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
        results.append(value)
      }
    }
    return results
  }

  func getDiameter(for size: String, country: String) -> String? {
    let diameterKey = countries.first { $0.localizedCaseInsensitiveContains("diameter") || $0.contains("Other") }
    guard let diameterColumn = diameterKey else {
      print("❗️No diameter column found.")
      return nil
    }
    for entry in sizeTable {
      if let value = entry.sizes[country]?.trimmingCharacters(in: .whitespacesAndNewlines),
         value == size {
        return entry.sizes[diameterColumn]
      }
    }
    return nil
  }

}
