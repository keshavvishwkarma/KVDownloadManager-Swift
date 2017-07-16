//
//  KVCircularProgressView.swift
//  KVDownloadManager
//
//  Created by Keshav on 6/15/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

public protocol Progressable {
    var progress: CGFloat { set get }
}

@IBDesignable
open class KVCircularProgressView: KVBaseView, Progressable
{
    /// Value of progress now. Range 0.0....1.0
    @IBInspectable open var progress: CGFloat {
        get {
            return self.circularLayer.progress
        }
        
        set {
            self.circularLayer.progress = newValue
        }
    }
    
    override open func initialSetup() {
        super.initialSetup()

        circularLayer.strokeColor = tintColor.withAlphaComponent(0.4).cgColor
    }
    
}

@IBDesignable
open class KVBaseView: UIView {
    
    @IBInspectable open var strokeWidth: CGFloat = 6 {
        didSet{
            circularLayer.lineWidth = strokeWidth
        }
    }
    
    public private(set) lazy var circularLayer : KVCircularLayer = {
        let layer = KVCircularLayer()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    override open func prepareForInterfaceBuilder() {
        self.initialSetup()
        super.prepareForInterfaceBuilder()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.initialSetup()
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        circularLayer.strokeColor = tintColor.cgColor
        circularLayer.progressLayer.strokeColor = tintColor.cgColor
    }
    
    open func initialSetup() {
        let insetRect = bounds.insetBy(dx: layer.borderWidth, dy: layer.borderWidth)
        let value = min(insetRect.width, insetRect.height)
        circularLayer.frame = CGRect(x: 0, y: 0, width: value, height: value)
        
        tintColorDidChange()
    }
    
}

open class KVCircularLayer: CAShapeLayer, Progressable
{
    public private(set) lazy var progressLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.fillColor
        layer.lineCap   = kCALineCapRound
        self.addSublayer(layer)
        return layer
    }()
    
    /// Value of progress now. Range 0.0....1.0
    open var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = max(0, min(progress, 1))
        }
    }
    
    public override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var lineWidth: CGFloat {
        didSet{
            initialSetup()
        }
    }
    
    override open var borderWidth: CGFloat{
        didSet{
            initialSetup()
        }
    }
    
    override open var frame: CGRect{
        didSet{
            initialSetup()
        }
    }
    
    override open var path: CGPath?{
        didSet{
            progressLayer.path = self.path
        }
    }
    
    func initialSetup()
    {
        if bounds != .zero {
            let insetRect = bounds.insetBy(dx: lineWidth * 0.5 + borderWidth, dy: lineWidth * 0.5 + borderWidth)
            let radius =  min(insetRect.height, insetRect.width)*0.5
            let bezierPath = UIBezierPath(roundedRect: insetRect, cornerRadius:radius)
            self.path = bezierPath.cgPath
        }
        
        if strokeColor == nil {
            self.strokeColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        }
        
        // Track Layer
        progressLayer.frame     = bounds
        progressLayer.lineWidth = lineWidth
        
        if progressLayer.strokeColor == nil {
            progressLayer.strokeColor = UIColor.blue.cgColor
        }
    }
    
    public final func setProgress(_ progress: CGFloat, animated: Bool , completion : (() -> Swift.Void)? = nil )
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        if animated {
            CATransaction.setAnimationDuration(0.5)
            let timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
            CATransaction.setAnimationTimingFunction(timingFunction)
        }
        self.progress = progress
        CATransaction.commit()
    }
    
}
