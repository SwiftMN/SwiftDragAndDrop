//
//  Puzzle.swift
//  SwiftPuzzle
//
//  Created by Adam Ahrens on 6/14/17.
//  Copyright © 2017 Appsbyahrens. All rights reserved.
//

import UIKit

struct Puzzle {

  private let originalImages: [UIImage]

  init(image: UIImage, square: Int) {
    let scale = image.scale
    let width = (image.size.width * scale) / CGFloat(square)
    let height = (image.size.height * scale) / CGFloat(square)

    var images = [UIImage]()

    var y = CGFloat(0.0)
    for _ in 0..<square {
      var x = CGFloat(0.0)
      for _ in 0..<square {
        let rect = CGRect(x: x, y: y, width: width, height: height)
        if let cgimage = image.cgImage?.cropping(to: rect) {
          let square = UIImage(cgImage: cgimage, scale: scale, orientation: image.imageOrientation)
          images.append(square)
        }

        x += width
      }

      y += height
    }

    self.originalImages = images
  }

  func squares() -> Int {
    return originalImages.count
  }

  func image(at: Int) -> UIImage {
    guard at >= 0 && at < originalImages.count else {
      fatalError("You're an idiot")
    }

    return originalImages[at]
  }
}
