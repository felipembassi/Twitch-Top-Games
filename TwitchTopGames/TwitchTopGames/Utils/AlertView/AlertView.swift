//
//  AlertView.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 08/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

protocol AlertViewDelegate: class {
    func okButtonTapped(handler: (() -> Void)?)
    func cancelButtonTapped(handler: (() -> Void)?)
}

class AlertView: UIViewController {
    
    //MARK: Vars and Lets
    var delegate: AlertViewDelegate?
    var handlerOk: (() -> Void)?
    var handlerCancel: (() -> Void)?
    var alertTitle: String?
    var message: String?
    var cancelTitle: String?
    var okTitle: String?
    var hideCancel: Bool?
    var hideSeparator: Bool?
    var cancelColor: UIColor?
    var okColor: UIColor?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleAlert.text = alertTitle ?? ""
        descriptionAlert.text = message ?? ""
        cancelButton.setTitle(cancelTitle ?? K.Buttons.cancel, for: .normal)
        sendButton.setTitle(okTitle ?? K.Buttons.alertOkButton, for: .normal)
        cancelButton.isHidden = hideCancel ?? false
        viewSeparator.isHidden = hideSeparator ?? false
        sendButton.setTitleColor(okColor ?? .defaultPurple, for: .normal)
        cancelButton.setTitleColor(cancelColor ?? .defaultRed, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateView()
    }
    
    //MARK: IBOutlets
    
    @IBOutlet weak var titleAlert: UILabel!
    @IBOutlet weak var descriptionAlert: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewSeparator: UIView!
    
    //MARK: IBActions
    @IBAction func cancelButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        if let cancel = handlerCancel {
            cancel()
        }
        
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        if let confirm = handlerOk {
            confirm()
        }
        
    }
    
    //MARK: Methods
    func animateView() {
        alertView.alpha = 0
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //            centerConstraint.constant = keyboardSize.height + 50
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
