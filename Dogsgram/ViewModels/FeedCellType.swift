//
//  FeedCellType.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import Foundation

enum FeedCellType {
    case image(viewModel: ImageCollectionViewCellViewModel)
    case likes(viewModel: LikesCollectionViewCellViewModel)
}
