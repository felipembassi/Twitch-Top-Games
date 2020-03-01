//
//  PlaceholderView.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 08/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import UIKit


/// Class used to generate placeholder views for a UITableViewController
/// Change parameters according to necessity
/// usage:
/// let placeholder = TableViewPlaceHolder()
/// placeholder.placeholderTitle.text = "title"

class TableViewPlaceholder: UIView {
    
    @IBOutlet var contentView: UIView!
    ///Placeholder Title
    @IBOutlet weak var placeholderTitle: UILabel!
    ///Placeholder Description
    @IBOutlet weak var placeHolderDescription: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TableViewPlaceholder", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

