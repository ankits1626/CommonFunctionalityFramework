//
//  UILoadControl.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 21/05/21.
//  Copyright © 2021 Rewardz. All rights reserved.
//

import UIKit
import Foundation

public class CFFLoadControl: UIControl {
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    private var originalDelegate: UIScrollViewDelegate?
    
    internal weak var target: AnyObject?
    internal var action: Selector!
    
    public var heightLimit: CGFloat = 80.0
    public fileprivate (set) var loading: Bool = false
    
    var scrollView: UIScrollView = UIScrollView()
    
    override public var frame: CGRect {
        didSet{
            if (frame.size.height > heightLimit) && !loading {
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public init(target: AnyObject?, action: Selector) {
        self.init()
        self.initialize()
        self.target = target
        self.action = action
        addTarget(self.target, action: self.action, for: .valueChanged)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /*
     Update layout at finsih to load
     */
    public func endLoading(){
        self.setLoading(isLoading: false)
        self.fixPosition()
    }
    
    public func update() {
        updateUI()
    }
}

extension CFFLoadControl {
    
    /*
     Initilize the control
     */
    fileprivate func initialize(){
        self.addTarget(self, action: #selector(CFFLoadControl.didValueChange(sender:)), for: .valueChanged)
        setupActivityIndicator()
    }
    
    /*
     Check if the control frame should be updated.
     This method is called after user hits the end of the scrollView
     */
    func updateUI(){
        if self.scrollView.contentSize.height < self.scrollView.bounds.size.height {
            return
        }
        
        let contentOffSetBottom = max(0, ((scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height))
        if (contentOffSetBottom >= 0 && !loading) || (contentOffSetBottom >= heightLimit && loading) {
            self.updateFrame(rect: CGRect(x:0.0, y:scrollView.contentSize.height, width:scrollView.frame.size.width, height:contentOffSetBottom))
        }
    }
    
    /*
     Update layout after user scroll the scrollView
     */
    private func updateFrame(rect: CGRect){
        guard let superview = self.superview else {
            return
        }
        
        superview.frame = rect
        frame = superview.bounds
        activityIndicatorView.alpha = (((frame.size.height * 100) / heightLimit) / 100)
        activityIndicatorView.center = CGPoint(x:(frame.size.width / 2), y:(frame.size.height / 2))
    }
    
    /*
     Place control at the scrollView bottom
     */
    fileprivate func fixPosition(){
        self.updateFrame(rect: CGRect(x:0.0, y:scrollView.contentSize.height, width:scrollView.frame.size.width, height:0.0))
    }
    
    /*
     Set layout to a "loading" or "not loading" state
     */
    fileprivate func setLoading(isLoading: Bool){
        loading = isLoading
        DispatchQueue.main.async { [unowned self] in
            
            var contentInset = self.scrollView.contentInset
            
            if self.loading {
                contentInset.bottom = self.heightLimit
                self.activityIndicatorView.startAnimating()
            }else{
                contentInset.bottom = 0.0
                self.activityIndicatorView.stopAnimating()
            }
            
            self.scrollView.contentInset = contentInset
        }
    }
    
    /*
     Prepare activityIndicator
     */
    private func setupActivityIndicator(){
        
        if self.activityIndicatorView != nil {
            return
        }
        
        self.activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        self.activityIndicatorView.hidesWhenStopped = false
        self.activityIndicatorView.color = UIColor.darkGray
        self.activityIndicatorView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        
        addSubview(self.activityIndicatorView)
        bringSubviewToFront(self.activityIndicatorView)
    }
    
    @objc fileprivate func didValueChange(sender: AnyObject?){
        setLoading(isLoading: true)
    }
    
}

extension UIScrollView {
    
    /*
     Add new variables to UIScrollView class
     
     UIControls can only be placed as subviews of UITableView.
     So we had to place UILoadControl inside a UIView "loadControlView" and place "loadControlView" as a subview of UIScrollView.
     */
    
    private struct AssociatedKeys {
        static var delegate: UIScrollViewDelegate?
        static var loadControl: CFFLoadControl?
        fileprivate static var loadControlView: UIView?
    }
    
    /*
     UILoadControl object
     */
    public var loadCFFControl: CFFLoadControl? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControl) as? CFFLoadControl
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControl, newValue as CFFLoadControl?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.updateLoadControl()
            }
        }
    }
    
    /*
     UILoadControl view containers
     */
    fileprivate var loadCFFControlView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControlView) as? UIView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControlView, newValue as UIView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIScrollView {
    
    public func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    fileprivate func updateLoadControl() {
        guard let loadControl = self.loadCFFControl else {
            return
        }
        
        loadControl.scrollView = self
        return setupLoadControlViewWithControl(control: loadControl)
    }
    
    
    fileprivate func setupLoadControlViewWithControl(control: CFFLoadControl) {
        
        guard let loadControlView = self.loadCFFControlView else {
            self.loadCFFControlView = UIView()
            self.loadCFFControlView?.clipsToBounds = true
            self.loadCFFControlView?.addSubview(control)
            return addSubview(self.loadCFFControlView!)
        }
        
        if loadControlView.subviews.contains(control) {
            return
        }
        
        return loadControlView.addSubview(control)
    }
}
