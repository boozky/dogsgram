//
//  LikesCollectionViewCell.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import UIKit

protocol LikesCollectionViewCellDelegate: AnyObject {
    func likesCollectionViewCellDidLikeChanged(_ cell: LikesCollectionViewCell, isLiked: Bool)
}

class LikesCollectionViewCell: UICollectionViewCell {
    public static let identifier = "LikesCollectionViewCell"
    weak var delegate: LikesCollectionViewCellDelegate?
    public var viewModel: LikesCollectionViewCellViewModel?
    
    private let likeButton: LikeButton = {
        let likeButton = LikeButton()
        likeButton.frame = CGRect(x: 20, y: 0, width: 25, height: 25)
        likeButton.buttonShape = .heart
        likeButton.addTarget(self, action: #selector(changeLikeCount), for: .touchUpInside)
        return likeButton
    }()
    
    private let likeLabel: UILabel = {
        let likeLabel = UILabel()
        likeLabel.textColor = .label
        likeLabel.textAlignment = .left
        likeLabel.frame = CGRect(x: 20, y: 25, width: 100, height: 25)
        return likeLabel
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.contentMode = .scaleAspectFit
        stackView.alignment = .leading
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likeLabel)
        contentView.addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: nil,
                         trailing: nil,
                         padding: UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 0))
    }
    
    func configure(with viewModel: LikesCollectionViewCellViewModel) {
        self.viewModel = viewModel
        let labelDesc = viewModel.likesCount == 1 ? "like" : "likes"
        likeLabel.text = "\(viewModel.likesCount) \(labelDesc)"
        likeButton.isLiked = viewModel.isLiked
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeButton.isLiked = false
        likeLabel.text = nil
    }
    
    @objc func changeLikeCount() {
        guard self.viewModel != nil else { return }
        let likesCount = viewModel!.likesCount
        if viewModel!.isLiked {
            self.viewModel?.likesCount = likesCount - 1
            self.viewModel?.isLiked = false
        } else {
            self.viewModel?.likesCount = likesCount + 1
            self.viewModel?.isLiked = true
        }
        configure(with: viewModel!)
        delegate?.likesCollectionViewCellDidLikeChanged(self, isLiked: viewModel!.isLiked)
    }
}
