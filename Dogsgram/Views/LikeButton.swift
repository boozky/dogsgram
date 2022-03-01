//
//  LikeButton.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/22/22.
//

import UIKit

enum LikeButtonShape {
    case heart
    case star
    case customSFSymbol(systemName: String)
    
    func getShapeImageName(filled: Bool) -> String {
        switch self {
        case .heart:
            return filled ? "heart.fill" : "heart"
        case .star:
            return filled ? "star.fill" : "star"
        case .customSFSymbol(systemName: let systemName):
            return filled ? "\(systemName).fill" : systemName
        }
    }
}

class LikeButton: UIButton {

    var isLiked: Bool = false {
        didSet {
            setSelected()
        }
    }
    
    var buttonShape: LikeButtonShape = .heart {
        didSet {
            likeImageDeselected = UIImage(systemName: buttonShape.getShapeImageName(filled: false))
            likeImageSelected = UIImage(systemName: buttonShape.getShapeImageName(filled: true))
            self.setImage(isLiked ? likeImageSelected : likeImageDeselected, for: .normal)
        }
    }
    
    private var likeImageDeselected: UIImage? = nil
    private var likeImageSelected: UIImage? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        self.buttonShape = .heart
        setSelected()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTap() {
        isLiked = !isLiked
        setSelected()
    }

    func setSelected() {
        self.setImage(isLiked ? likeImageSelected : likeImageDeselected, for: .normal)
        self.imageView?.tintColor = isLiked ? .red : .label
    }
}
