//
//  SearchResultCollectionViewCell.swift
//  Dispo Take Home
//
//  Created by Andrii Kurshyn on 7/10/21.
//

import UIKit

class SearchResultCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(16)
            maker.top.bottom.equalToSuperview().inset(9)
            maker.width.height.equalTo(90)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(imageView.snp.right).offset(16)
            maker.top.bottom.equalToSuperview()
            maker.right.equalToSuperview().inset(24)
        }
    }
}
