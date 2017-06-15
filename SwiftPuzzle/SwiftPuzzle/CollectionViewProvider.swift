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
  private var puzzle: Puzzle
  private let size = 5

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
    self.puzzle = Puzzle(image: #imageLiteral(resourceName: "Puzzle"), square: size)

    super.init()

    self.collectionView?.dataSource = self
    self.collectionView?.delegate = self

    //MARK: Drag & Drop
    self.collectionView?.dragDelegate = self
    self.collectionView?.dropDelegate = self
  }
}

//MARK: UICollectionViewDragDelegate
extension CollectionViewProvider: UICollectionViewDragDelegate {
  func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    // Need an object
    let image = puzzle.image(at: indexPath.row)

    // Need an itemProvider to server up the image
    let itemProvider = NSItemProvider(object: image)

    // Need to make a UIDragItem w/ an NSItemProvider
    let dragItem = UIDragItem(itemProvider: itemProvider)

    // Use localObject to attach additional information to
    // this drag item, visible only inside the app that started the drag
    dragItem.localObject = image

    // Update a previewProvider to show your custom UIView
    // When a drag is started. NOTE: Bug in Seed 1, SEE BELOW
    dragItem.previewProvider = image.dragPreviewProvider

    // A DragSession will be started as long as this array isn't empty
    return [dragItem]
  }

  func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
    print("Drag Session Will Begin")

    // This is a workaround for an issue in Seed 1 where a previewProvider set before the drag session begins isn't used. This code will not be necessary in a future seed.
    for dragItem in session.items {
      if let image = dragItem.localObject as? UIImage {
        dragItem.previewProvider = image.dragPreviewProvider
      }
    }
  }

  func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
    print("Drag Session Did End. Cleanup")
  }
}

//MARK: UICollectionViewDropDelegate
extension CollectionViewProvider: UICollectionViewDropDelegate {
  public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
    guard let finalIndexPath = coordinator.destinationIndexPath, coordinator.proposal.operation == .move else { return }

    // Where we dropping this unit?
    let hasSourceIndexPath = coordinator.items.contains { collectionViewDropItem in
      return collectionViewDropItem.sourceIndexPath != nil
    }

    // Are we truly moving 1 item?
    if let item = coordinator.items.first, let sourceIndexPath = coordinator.items.first?.sourceIndexPath, coordinator.items.count == 1 && hasSourceIndexPath {
      collectionView.performBatchUpdates({ [weak self] in
        print("Performing Batch Updates")

        // Update model
        self?.puzzle.swap(from: sourceIndexPath.row, to: finalIndexPath.row)

        //Update collectionView
        self?.collectionView?.deleteItems(at: [sourceIndexPath])
        self?.collectionView?.insertItems(at: [finalIndexPath])
      }) { complete in
        print("Completed Batch Updates")
      }

      // Add drop animation
      coordinator.drop(item.dragItem, toItemAt: finalIndexPath)
    }
  }

  public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
    return UICollectionViewDropProposal(dropOperation: .move, intent: .insertAtDestinationIndexPath)
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
    return 0.0
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
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

//MARK: UIImage
extension UIImage {
  var dragPreviewProvider: () -> UIDragPreview {
    return {
      print("Drag Item Preview Provider called")
      let imageView = UIImageView(image: self)
      imageView.alpha = 0.8
      imageView.layer.masksToBounds = true
      imageView.layer.cornerRadius = min(self.size.width, self.size.height) / 2.0
      return UIDragPreview(view: imageView)
    }
  }
}
