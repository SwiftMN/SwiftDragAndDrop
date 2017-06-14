//
//  CollectionViewProvider.swift
//  SwiftPuzzle
//
//  Created by Adam Ahrens on 6/14/17.
//  Copyright © 2017 Appsbyahrens. All rights reserved.
//

import UIKit

final class CollectionViewProvider: NSObject {

  private weak var collectionView: UICollectionView?
  private let puzzle: Puzzle
  private let size = 5

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
    self.puzzle = Puzzle(image: #imageLiteral(resourceName: "Puzzle"), square: size)

    super.init()

    self.collectionView?.dataSource = self
    self.collectionView?.delegate = self
  }
}

//MARK: UICollectionViewDelegateFlowLayout
extension CollectionViewProvider: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let minimum = min(collectionView.frame.width, collectionView.frame.height)
    let square = minimum / CGFloat(size)
    return CGSize(width: square, height: square)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1.0
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1.0
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
}

//MARK: UICollectionViewDataSource
extension CollectionViewProvider: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return puzzle.squares()
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PuzzleCell", for: indexPath) as! PuzzleCollectionViewCell
    let image = puzzle.image(at: indexPath.row)
    cell.imageView.image = image
    return cell
  }
}
