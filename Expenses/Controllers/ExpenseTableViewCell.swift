//
//  File.swift
//  Expenses
//
//  Created by Agterra on 01/07/2019.
//  Copyright © 2019 Agterra. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    var title: String!
    var amount: Float!
    var titleLabel: UILabel!
    var amountLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title: String, and amount: Float, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        self.set(title: title,
                 and: amount)
        self.setupView()
        self.setupConstraints()
    }
    
    public func set(title: String, and amount: Float) {
        self.title = title
        self.amount = amount
    }
    
    private func setupView() {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont(name: Settings.fontFamily,
                                 size: Settings.fontSize)
        titleLabel.numberOfLines = 0
        titleLabel.text = self.title
        self.titleLabel = titleLabel
        
        self.addSubview(self.titleLabel)
        
        let amountLabel = UILabel(frame: .zero)
        amountLabel.font = UIFont(name: Settings.fontFamily,
                                  size: Settings.fontSize)
        amountLabel.numberOfLines = 0
        amountLabel.textAlignment = .right
        if self.amount < 0 {
            amountLabel.textColor = Settings.redColor
            amountLabel.text = "\(self.amount ?? 0) €"
        } else {
            amountLabel.textColor = Settings.greenColor
            amountLabel.text = "+\(self.amount ?? 0) €"
        }
        self.amountLabel = amountLabel
        self.addSubview(amountLabel)
    }
    
    private func setupConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor,
                                                  constant: 20),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                                 constant: 10),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                    constant: -10),
            self.titleLabel.rightAnchor.constraint(equalTo: self.centerXAnchor,
                                                   constant: 40),
            
            self.amountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.amountLabel.leftAnchor.constraint(equalTo: self.centerXAnchor,
                                                  constant: 60),
            self.amountLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                                 constant: 10),
            self.amountLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                    constant: -10),
            self.amountLabel.rightAnchor.constraint(equalTo: self.rightAnchor,
                                                   constant: -20)
            ])
    }
}
