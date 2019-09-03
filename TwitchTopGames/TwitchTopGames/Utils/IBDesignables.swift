//
//  Appearence.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 03/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @discardableResult
    func addBlur(style: UIBlurEffect.Style = .extraLight) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        
        addSubview(blurBackground)
        sendSubviewToBack(blurBackground)
        
        blurBackground.translatesAutoresizingMaskIntoConstraints = false
        blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        return blurBackground
    }
    
    func addInnerShadow(to edges:[UIRectEdge], radius:CGFloat){
        
        let toColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        let fromColor = UIColor(red: 188.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        // Set up its frame.
        let viewFrame = self.frame
        for edge in edges{
            let gradientlayer          = CAGradientLayer()
            gradientlayer.colors       = [fromColor.cgColor,toColor.cgColor]
            gradientlayer.shadowRadius = radius
            
            switch edge {
            case UIRectEdge.top:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.bottom:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.frame = CGRect(x: 0.0, y: viewFrame.height - gradientlayer.shadowRadius, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.left:
                gradientlayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            case UIRectEdge.right:
                gradientlayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.frame = CGRect(x: viewFrame.width - gradientlayer.shadowRadius, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            default:
                break
            }
            self.layer.addSublayer(gradientlayer)
        }
        
    }
    
    func removeAllSublayers(){
        if let sublayers = self.layer.sublayers, !sublayers.isEmpty{
            for sublayer in sublayers{
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func circleView() {
        let halfWidth = self.layer.frame.size.height/2
        self.layer.cornerRadius = halfWidth
        self.layer.masksToBounds = true
    }
    
    /// Fade in a view with a duration
    ///
    /// Parameter duration: custom animation duration
    func fadeIn(withDuration duration: TimeInterval = 0.7, withAlpha alpha: CGFloat = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    /// Fade out a view with a duration
    ///
    /// - Parameter duration: custom animation duration
    func fadeOut(withDuration duration: TimeInterval = 0.7, withAlpha alpha: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    func growFromCenter(withDuration duration: TimeInterval = 0.7) {
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform.identity
        })
    }
}

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        if (isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
    
}

@IBDesignable
class RLRoundedProgressView: UIView {
    
    
    //====================================
    //MARK: Properties
    //====================================
    private var progressBackgroundView : UIView?
    private var progressBarView : UIView?
    
    private var progressBarViewWidthConstraint : NSLayoutConstraint?
    
    //Colors
    @IBInspectable var progressBackgroundColor : UIColor = UIColor(white: 1.0, alpha: 0.5){
        didSet{
            self.progressBackgroundView?.backgroundColor = progressBackgroundColor
        }
    }
    @IBInspectable var progressBarColor : UIColor = .white{
        didSet{
            self.progressBarView?.backgroundColor = progressBarColor
        }
    }
    
    //Paddings
    @IBInspectable var verticalPadding : CGFloat = 8.0
    @IBInspectable var horizontalPadding : CGFloat = 8.0
    
    //Paddings
    @IBInspectable var progressPercent: CGFloat = 50.0
    
    //Direction
    @IBInspectable var isRTL: Bool = false
    
    //====================================
    //MARK: ============== Implementation ==============
    //====================================
    override func draw(_ rect: CGRect) {
        
        self.progressBackgroundView = self.makeProgressBarView(withColor: self.progressBackgroundColor)
        self.addSubview(self.progressBackgroundView!)
        self.progressBarView = self.makeProgressBarView(withColor: self.progressBarColor)
        self.addSubview(self.progressBarView!)
        
        self.setConstraints()
    }
    
    
    
    //====================================
    //MARK: Make views
    //====================================
    private func makeProgressBarView(withColor color:UIColor) -> UIView{
        
        //Get frame
        let progressViewWidth = self.frame.size.width - (self.horizontalPadding * 2)
        let progressViewHeight = self.frame.size.height - (self.verticalPadding * 2)
        
        //Make view
        let progressView = UIView(frame: CGRect(x: 0, y: 0, width: progressViewWidth, height: progressViewHeight))
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = progressViewHeight/2
        
        
        //Set color
        progressView.backgroundColor = color
        
        //Return
        return progressView
    }
    
    
    
    //====================================
    //MARK: Set constraints
    //====================================
    private func setConstraints(){
        
        
        //Background constraints
        self.progressBackgroundView!.translatesAutoresizingMaskIntoConstraints = false
        var topSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                    attribute: .top, relatedBy: .equal,
                                                    toItem: self, attribute: .top,
                                                    multiplier: 1,
                                                    constant: self.verticalPadding)
        
        var bottomSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: self, attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: -self.verticalPadding)
        
        let leadingSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .leading,
                                                        multiplier: 1,
                                                        constant: self.horizontalPadding)
        
        let trailingSpaceConstraint = NSLayoutConstraint(item: self.progressBackgroundView!,
                                                         attribute: .trailing,
                                                         relatedBy: .equal,
                                                         toItem: self,
                                                         attribute: .trailing,
                                                         multiplier: 1,
                                                         constant: -self.horizontalPadding)
        
        self.addConstraints([topSpaceConstraint,
                             bottomSpaceConstraint,
                             leadingSpaceConstraint,
                             trailingSpaceConstraint])
        
        
        
        
        //Progress constraints
        self.progressBarView!.translatesAutoresizingMaskIntoConstraints = false
        topSpaceConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: self.verticalPadding)
        
        bottomSpaceConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: -self.verticalPadding)
        
        
        let leadingStickConstraint : NSLayoutConstraint //Stick to the trailing if RTL
        if self.isRTL{
            leadingStickConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                        attribute: .trailing,
                                                        relatedBy: .equal,
                                                        toItem: self.progressBackgroundView,
                                                        attribute: .trailing,
                                                        multiplier: 1,
                                                        constant: 0.0)
        }else{
            leadingStickConstraint = NSLayoutConstraint(item: self.progressBarView!,
                                                        attribute: .leading,
                                                        relatedBy: .equal,
                                                        toItem: self.progressBackgroundView,
                                                        attribute: .leading,
                                                        multiplier: 1,
                                                        constant: 0.0)
        }
        
        
        let progressWidth = self.progressBackgroundView!.frame.size.width * (self.progressPercent / 100.0)
        self.progressBarViewWidthConstraint = NSLayoutConstraint(item: self.progressBarView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: progressWidth)
        
        self.addConstraints([topSpaceConstraint,bottomSpaceConstraint,leadingStickConstraint,self.progressBarViewWidthConstraint!])
    }
    
    
    //====================================
    //MARK: Set progress
    //====================================
    func setProgress(percent:CGFloat){
        self.progressPercent = percent
        self.progressBarViewWidthConstraint?.constant = self.progressBackgroundView!.frame.size.width * (percent / 100.0)
        self.layoutIfNeeded()
    }
}
