//
//  ImageCollectionViewCell.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import UIKit

protocol ImageCollectionViewCellDelegate: AnyObject {
    func imageCollectionViewCellDidLikeChanged(_ cell: ImageCollectionViewCell, isLiked: Bool)
}

class ImageCollectionViewCell: UICollectionViewCell {
    public static let identifier = "ImageCollectionViewCell"
    weak var delegate: ImageCollectionViewCellDelegate?
    public var viewModel: ImageCollectionViewCellViewModel?
    
    private let imageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let likeImageView: UIImageView = {
        let likeBtnShape: LikeButtonShape = .heart //TODO: implement theme for the app, and read this value from there, make it consistent with like button in LikeCollectionViewCell
        let image = UIImage(systemName: likeBtnShape.getShapeImageName(filled: true))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(likeImageView)
        configureGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        let heartSize: CGFloat = 60
        likeImageView.frame = CGRect(x: (contentView.frame.width-heartSize)/2,
                                      y: (contentView.frame.height-heartSize)/2,
                                      width: heartSize,
                                      height: heartSize)
    }
    
    private func configureGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTap)
    }
    
    @objc func didDoubleTap() {
        likeImageView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.likeImageView.alpha = 1
        } completion: {[weak self] done in
            if done {
                UIView.animate(withDuration: 0.3) {
                    self?.likeImageView.alpha = 0
                } completion: { done in
                    if done {
                        self?.likeImageView.isHidden = true
                        self?.delegate?.imageCollectionViewCellDidLikeChanged(self!, isLiked: true)
                    }
                }
            }
        }
    }
    
    func configure(with viewModel: ImageCollectionViewCellViewModel) {
        self.viewModel = viewModel
        imageView.loadImaveWithUrl(viewModel.imageURL)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

extension ImageCollectionViewCell {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                self?.imageView.image = UIImage(data: data)
            }
        }
    }
}
