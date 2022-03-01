//
//  SpinnerCollectionViewCell.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/26/22.
//

import UIKit

class SpinnerCollectionViewCell: UICollectionViewCell {
    public static let identifier = "SpinnerCollectionViewCell"
    
    let spinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = contentView.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startSpinning() {
        spinner.startAnimating()
    }
}
