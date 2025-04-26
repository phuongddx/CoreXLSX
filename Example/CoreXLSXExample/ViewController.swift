//
//  ViewController.swift
//  CoreXLSX
//
//  Created by Max Desiatov on 11/07/2018.
//  Copyright (c) 2018 Max Desiatov. All rights reserved.
//

import CoreXLSX
import UIKit

class ViewController: UIViewController {
  @IBOutlet var label: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let path = Bundle.main.path(forResource: "RingSizes", ofType: "xlsx") else { return }
    do {
      let converter = try RingSizeConverter(filePath: path)
      converter.printSizeTable()
      converter.getSizes(for: "UK")
      converter.getDiameter(for: "2.5", country: "UK")
      if let result = converter.convert(size: "2.5") {
        print("Size 6 US = \(result) UK")
      } else {
        print("Size not found.")
      }
    } catch {
      print("Error reading file: \(error)")
    }
  }
}
