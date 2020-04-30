//
//  Stepper.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol StepperDelegate {
    func stepperDidChanged(sender: Stepper)
}

@IBDesignable class Stepper: UIControl {
    //MARK:- Properties
    @IBInspectable var incrementIndicatorColor: UIColor = UIColor.white
    @IBInspectable var decrementIndicatorColor: UIColor = UIColor.white
    @IBInspectable var borderColor: UIColor = UIColor.white
    @IBInspectable var textColor: UIColor = UIColor.lightGray
    @IBInspectable var middleColor: UIColor = UIColor.white
    @IBInspectable var cornerRadius: CGFloat = 12.0
    @IBInspectable var borderWidth: CGFloat = 2.0
    @IBInspectable var minVal: NSNumber?
    @IBInspectable var maxVal: NSNumber?
    @IBInspectable var quantityErrorMessage: String?
    @IBInspectable var delta: Int = 1
    @IBInspectable var incrementImage: UIImage?
    @IBInspectable var decrementImage: UIImage?
    var delegate: StepperDelegate?
    
    private var incrementButton = UIButton(frame: CGRect.zero)
    private var decrementButton = UIButton(frame: CGRect.zero)
    fileprivate var counterTxt  = UITextView(frame: CGRect.zero)
    
    override var isEnabled: Bool{
        didSet {
            isUserInteractionEnabled = isEnabled
        }
    }
    
    @IBInspectable var reading: Int = 0 {
        didSet {
            counterTxt.text = "\(reading)"
        }
    }
    
    private func insertControlSubViews() {
        decrementButton.addTarget(self, action: #selector(decrement), for: .touchUpInside)
        
        incrementButton.addTarget(self, action: #selector(increment), for: .touchUpInside)
        counterTxt.textAlignment = .center
        
        self.addSubview(decrementButton)
        self.addSubview(incrementButton)
        self.addSubview(counterTxt)
    }
    
    func setupStepperControl() {
        insertControlSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStepperControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStepperControl()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth = self.frame.size.height
        var counterLabelWidth = self.frame.size.width - (2 * buttonWidth)
        counterLabelWidth =  counterLabelWidth > 0 ? counterLabelWidth : 20.0
        let leftButtonframe  = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height)
        let rightButtonFrame = CGRect(x: (buttonWidth + counterLabelWidth), y: 0, width: self.frame.size.height, height: self.frame.size.height)
        
        let counterLabelFrame = CGRect(x: buttonWidth, y: 0, width: counterLabelWidth, height: self.frame.size.height)
        self.decrementButton.frame = leftButtonframe
        self.incrementButton.frame = rightButtonFrame
        self.counterTxt.frame = counterLabelFrame
        counterTxt.layer.borderWidth = borderWidth
        counterTxt.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
        counterTxt.backgroundColor = middleColor
        counterTxt.textColor = textColor
        counterTxt.keyboardType = .numberPad
        decrementButton.backgroundColor = decrementIndicatorColor
        incrementButton.backgroundColor = incrementIndicatorColor
        decrementButton.setTitle("-", for: UIControl.State.normal)
        incrementButton.setTitle("+", for: UIControl.State.normal)
        setNeedsDisplay()
        NotificationCenter.default.addObserver(self, selector: #selector(readingDidChanged(notification:)), name: UITextView.textDidChangeNotification, object: counterTxt)
    }
    
    @objc func increment() {
        if self.isEnabled == true{
            if let maxVal = self.maxVal?.intValue {
                let compReading = reading + delta
                if compReading <= maxVal{
                    reading = compReading
                    self.delegate?.stepperDidChanged(sender: self)
                }
            }else{
                reading = reading + delta
                self.delegate?.stepperDidChanged(sender: self)
            }
        }
    }
    
    @objc func decrement() {
        if self.isEnabled {
            if let minVal = self.minVal?.intValue {
                let compReading = reading - delta
                if compReading >= minVal{
                    reading = compReading
                    self.delegate?.stepperDidChanged(sender: self)
                }
            } else {
                reading = reading - delta
                self.delegate?.stepperDidChanged(sender: self)
            }
        }
    }
}

extension Stepper: UITextFieldDelegate {
    @objc func readingDidChanged(notification: Notification)  {
        if counterTxt.text.isEmpty{
            reading = 0
        }else{
            reading = checkMaxLimitForStepper(enteredLimit: Int(self.counterTxt.text)!)
        }
        self.delegate?.stepperDidChanged(sender: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if counterTxt.text.isEmpty {
            self.counterTxt.text = "0"
        }
    }
    
    func checkMaxLimitForStepper(enteredLimit : Int) -> Int {
        if let maxVal = self.maxVal?.intValue {
            if enteredLimit <= maxVal{
                return enteredLimit
            }else{
                return reading
            }
        }
        return enteredLimit
    }
}
