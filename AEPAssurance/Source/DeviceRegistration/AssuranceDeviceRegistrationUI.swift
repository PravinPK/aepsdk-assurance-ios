/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import UIKit

class AssuranceDeviceRegistrationUI {
    
    private let horizontalMargin = 20.0
    private let verticalMargin = -35.0
    private let viewHeightPercent = 0.37
    
    private let BUTTON_HEIGHT = 45.0

    private let primaryBGColor = UIColor(red: 28.0 / 255.0, green: 31.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0)
    private let secondaryBGColor = UIColor(red: 54.0 / 255.0, green: 57.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
    private let primaryTextColor = UIColor.white
    private let secondaryTextColor = UIColor(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    
    private var prompt1 = UIView()
    private var prompt2 = UIView()
    private var dismissButton = UIButton()
    private let deviceManager : AssuranceDeviceManager
    
    
    private let registerDevicePending  = "   ⌛    Registering your device..."
    private let registerDeviceApproved = "   👍    Device successfully registered"
    private let registerDeviceFailed   = "   🔴    Device registration failed"
    
    private let deviceApprovalPending =  "   ⌛    Waiting for approval..."
    private let deviceApprovalSuccess =  "   👍    Device approved. Initiating griffon connection.."
    private let deviceApprovalFailed  =  "   🔴    Failed to connect device to a session"
    
    
    init(deviceManager : AssuranceDeviceManager) {
        self.deviceManager = deviceManager
    }
    
    func showPrompt() {
        guard let window = UIApplication.shared.assuranceGetKeyWindow() else {
            return
        }
        
        
        
        prompt.backgroundColor = primaryBGColor
        prompt.addSubview(headingLabel)
        prompt.addSubview(imageAdobeLogo)
        promptHolder.addSubview(prompt)
        

        
        NSLayoutConstraint.activate([
            imageAdobeLogo.leadingAnchor.constraint(equalTo: prompt.leadingAnchor),
            imageAdobeLogo.topAnchor.constraint(equalTo: prompt.layoutMarginsGuide.topAnchor),
            imageAdobeLogo.widthAnchor.constraint(equalToConstant: 50),
            imageAdobeLogo.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: prompt.layoutMarginsGuide.topAnchor),
            headingLabel.leadingAnchor.constraint(equalTo: imageAdobeLogo.layoutMarginsGuide.leadingAnchor),
            headingLabel.trailingAnchor.constraint(equalTo: prompt.layoutMarginsGuide.trailingAnchor),
            headingLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        designPrompt2()
        designPrompt1()
        
        window.addSubview(promptHolder)
        //window.addSubview(prompt)
        window.bringSubviewToFront(promptHolder)
        //window.bringSubviewToFront(prompt)
        
        let heightConstrain1 = prompt.heightAnchor.constraint(equalTo: promptHolder.heightAnchor, multiplier: viewHeightPercent)
        //let heightConstrain2 = alertView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        //heightConstrain1.priority = UILayoutPriority(999)
        //heightConstrain1.priority = UILayoutPriority(400)
        let constraints = [
            heightConstrain1,
            prompt.leftAnchor.constraint(equalTo: promptHolder.leftAnchor, constant: horizontalMargin),
            prompt.rightAnchor.constraint(equalTo: promptHolder.rightAnchor
                                             ,constant: -horizontalMargin),
            prompt.bottomAnchor.constraint(equalTo: promptHolder.bottomAnchor, constant: verticalMargin)
        ]
        NSLayoutConstraint.activate(constraints)
        
        
        NSLayoutConstraint.activate([
            promptHolder.leftAnchor.constraint(equalTo: window.leftAnchor),
            promptHolder.rightAnchor.constraint(equalTo: window.rightAnchor),
            promptHolder.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            promptHolder.topAnchor.constraint(equalTo: window.topAnchor)
        ])
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [self] in
            promptHolder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        }, completion: nil)

        
    }
    
    func designPrompt1() {
        prompt1.accessibilityLabel = "prompt 1"
        prompt1.backgroundColor = primaryBGColor
        prompt1.layer.cornerRadius = 20.0
        prompt1.translatesAutoresizingMaskIntoConstraints = false
        prompt1.clipsToBounds = true
        self.prompt.addSubview(prompt1)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Connect to a griffon session?"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont(name: "Helvetica", size: 18)
        descriptionLabel.numberOfLines = 99
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = secondaryTextColor
        descriptionLabel.baselineAdjustment = .alignCenters
        descriptionLabel.layer.cornerRadius = 5
        descriptionLabel.backgroundColor = secondaryBGColor
        descriptionLabel.clipsToBounds = true
        
        let termsLabel = UILabel()
        termsLabel.text = "TERMS: \n By Continuing, you are willing to connect and send Adobe Experience Platform SDK related information to Assurance session for debugging and evaluation purposes. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book"
        termsLabel.textAlignment = .justified
        termsLabel.font = UIFont(name: "Helvetica", size: 8)
        termsLabel.numberOfLines = 99
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.textColor = secondaryTextColor
        termsLabel.baselineAdjustment = .alignBaselines
        termsLabel.layer.cornerRadius = 5
        termsLabel.backgroundColor = secondaryBGColor
        termsLabel.clipsToBounds = true
        
                
        prompt1.addSubview(descriptionLabel)
        prompt1.addSubview(termsLabel)
        
        let continueButton = UIButton()
        continueButton.addTarget(self, action: #selector(self.moveClicked(_:)), for: .touchUpInside)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        prompt1.addSubview(continueButton)
        
        dismissButton.addTarget(self, action: #selector(dismissClicked), for: .touchUpInside)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        prompt1.addSubview(dismissButton)
        
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: termsLabel.topAnchor),
            descriptionLabel.heightAnchor.constraint(equalTo: termsLabel.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            termsLabel.leadingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.leadingAnchor),
            termsLabel.trailingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.trailingAnchor),
            termsLabel.topAnchor.constraint(equalTo: descriptionLabel.layoutMarginsGuide.topAnchor),
            termsLabel.bottomAnchor.constraint(equalTo: dismissButton.topAnchor),
            termsLabel.heightAnchor.constraint(equalTo: descriptionLabel.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.trailingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT),
            continueButton.bottomAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.bottomAnchor),
            continueButton.widthAnchor.constraint(equalTo: prompt.widthAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.leadingAnchor),
            dismissButton.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT),
            dismissButton.bottomAnchor.constraint(equalTo: prompt1.layoutMarginsGuide.bottomAnchor),
            dismissButton.widthAnchor.constraint(equalTo: prompt.widthAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            prompt1.leadingAnchor.constraint(equalTo: prompt.leadingAnchor),
            prompt1.trailingAnchor.constraint(equalTo: prompt.trailingAnchor),
            prompt1.topAnchor.constraint(equalTo: headingLabel.bottomAnchor),
            prompt1.bottomAnchor.constraint(equalTo: prompt.bottomAnchor)
        ])
    }
    
    func designPrompt2() {
        prompt2.accessibilityLabel = "prompt 2"
        prompt2.backgroundColor = primaryBGColor
        prompt2.translatesAutoresizingMaskIntoConstraints = false
        prompt2.clipsToBounds = true
        prompt2.layer.cornerRadius = 20.0
        self.prompt.addSubview(prompt2)
        
        
        let bgView = UIView()
        bgView.accessibilityLabel = "bgView"
        bgView.backgroundColor = secondaryBGColor
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        
            
        let cancelButton = UIButton()
        cancelButton.addTarget(self, action: #selector(self.cancelClicked(_:)), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        prompt2.addSubview(bgView)
        prompt2.addSubview(cancelButton)
        prompt2.addSubview(labelRegisteringDevice)
        prompt2.addSubview(labelDeviceApprovalStatus)
        prompt2.addSubview(labelDeviceApprovalHint)
        prompt2.addSubview(activityIndicator)
        
        labelDeviceApprovalStatus.isHidden = true
        labelDeviceApprovalHint.isHidden = true
        
 
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.leadingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT),
            cancelButton.bottomAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelRegisteringDevice.leadingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.leadingAnchor),
            labelRegisteringDevice.trailingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.trailingAnchor),
            labelRegisteringDevice.topAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.topAnchor),
            labelRegisteringDevice.bottomAnchor.constraint(equalTo: labelDeviceApprovalStatus.topAnchor),
            labelRegisteringDevice.heightAnchor.constraint(equalTo: labelDeviceApprovalStatus.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelDeviceApprovalStatus.leadingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.leadingAnchor),
            labelDeviceApprovalStatus.trailingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.trailingAnchor),
            labelDeviceApprovalStatus.topAnchor.constraint(equalTo: labelRegisteringDevice.layoutMarginsGuide.topAnchor),
            labelDeviceApprovalStatus.bottomAnchor.constraint(equalTo: labelDeviceApprovalHint.topAnchor),
            labelDeviceApprovalStatus.heightAnchor.constraint(equalTo: labelDeviceApprovalHint.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelDeviceApprovalHint.leadingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.leadingAnchor, constant: 55),
            labelDeviceApprovalHint.trailingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.trailingAnchor),
            labelDeviceApprovalHint.topAnchor.constraint(equalTo: labelDeviceApprovalStatus.layoutMarginsGuide.topAnchor, constant: -20),
            labelDeviceApprovalHint.bottomAnchor.constraint(equalTo: activityIndicator.topAnchor),
            labelDeviceApprovalHint.heightAnchor.constraint(equalTo: activityIndicator.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.heightAnchor.constraint(equalTo: labelRegisteringDevice.heightAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: prompt2.layoutMarginsGuide.trailingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: labelDeviceApprovalHint.layoutMarginsGuide.bottomAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: cancelButton.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: prompt2.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: prompt2.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: prompt2.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor)
        ])


        NSLayoutConstraint.activate([
            prompt2.leadingAnchor.constraint(equalTo: prompt.leadingAnchor),
            prompt2.trailingAnchor.constraint(equalTo: prompt.trailingAnchor),
            prompt2.topAnchor.constraint(equalTo: headingLabel.bottomAnchor),
            prompt2.bottomAnchor.constraint(equalTo: prompt.bottomAnchor)
        ])
    }
    

    func onSuccessfulDeviceRegistration() {
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.labelRegisteringDevice.text = self.registerDeviceApproved
            }, completion: {resut in
                self.labelDeviceApprovalStatus.isHidden = false
                self.labelDeviceApprovalHint.isHidden = false
            })
        }
    }
    
    func onFailedDeviceRegistration() {
        DispatchQueue.main.async {
            self.labelRegisteringDevice.text = self.registerDeviceFailed
        }
    }
    
    
    func onSuccessfulApproval() {
        DispatchQueue.main.async {
            self.labelDeviceApprovalStatus.text = self.deviceApprovalSuccess
            self.activityIndicator.stopAnimating()
            self.dismissRegistrationView()
        }

    }
    
    func onFailedApproval() {
        DispatchQueue.main.async {
            self.labelDeviceApprovalStatus.text = self.deviceApprovalFailed
            self.labelDeviceApprovalHint.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    
    @objc func moveClicked(_ sender: AnyObject?) {
        UIView.transition(from: prompt1, to: prompt2, duration: 1, options: [.curveEaseInOut], completion: nil)
        activityIndicator.startAnimating()
        deviceManager.createDevice()
    }
    
    
    @objc func dismissClicked() {
        dismissRegistrationView()
    }
    
    @objc func cancelClicked(_ sender: AnyObject?) {
        deviceManager.deleteDevice()
        dismissRegistrationView()
    }
    
    
    func dismissRegistrationView() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.assuranceGetKeyWindow() else {
                return
            }
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: { [self] in
                self.prompt.frame.origin.y = window.frame.size.height
                self.promptHolder.alpha = 0
            }, completion: { [self] _ in
                self.promptHolder.removeFromSuperview()
            })
        }
    
    }
    
    private let imageAdobeLogo : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(data: Data(bytes: adobeLogo.content, count: adobeLogo.content.count))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy private var headingLabel : UILabel = {
        let headingLabel = UILabel()
        headingLabel.text = "Assurance"
        headingLabel.textAlignment = .center
        headingLabel.font = UIFont(name: "Helvetica-Bold", size: 28)
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.textColor = primaryTextColor
        return headingLabel
    }()
    
    lazy private var prompt : UIView = {
        let prompt = UIView()
        prompt.layer.cornerRadius = 20.0
        prompt.accessibilityLabel = "Assurance Prompt"
        prompt.translatesAutoresizingMaskIntoConstraints = false
        return prompt
    }()
    
    lazy private var promptHolder : UIView = {
        let view = UIView()
        view.accessibilityLabel = "Prompt Holder"
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var labelRegisteringDevice : UILabel = {
        let registrationStatusLabel = UILabel()
        registrationStatusLabel.text = registerDevicePending
        registrationStatusLabel.textAlignment = .left
        registrationStatusLabel.font = UIFont(name: "Helvetica", size: 17)
        registrationStatusLabel.numberOfLines = 99
        registrationStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        registrationStatusLabel.textColor = secondaryTextColor
        registrationStatusLabel.baselineAdjustment = .alignCenters
        registrationStatusLabel.layer.cornerRadius = 2
        registrationStatusLabel.backgroundColor = secondaryBGColor
        registrationStatusLabel.clipsToBounds = true
        return registrationStatusLabel
    }()
    
    
    lazy private var labelDeviceApprovalStatus : UILabel = {
        let registrationStatusLabel = UILabel()
        registrationStatusLabel.textAlignment = .left
        registrationStatusLabel.text = deviceApprovalPending
        registrationStatusLabel.font = UIFont(name: "Helvetica", size: 17)
        registrationStatusLabel.numberOfLines = 2
        registrationStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        registrationStatusLabel.textColor = secondaryTextColor
        registrationStatusLabel.baselineAdjustment = .alignCenters
        registrationStatusLabel.layer.cornerRadius = 2
        registrationStatusLabel.backgroundColor = secondaryBGColor
        registrationStatusLabel.clipsToBounds = true
        
        return registrationStatusLabel
    }()
    
    lazy private var labelDeviceApprovalHint : UILabel = {
        let labelDeviceApprovalHint = UILabel()
        labelDeviceApprovalHint.textAlignment = .left
        labelDeviceApprovalHint.text = "Log in to griffon.adobe.com and approve Pravin's iPhone from the device prompt that appears."
        labelDeviceApprovalHint.font = UIFont(name: "Helvetica", size: 10)
        labelDeviceApprovalHint.numberOfLines = 99
        labelDeviceApprovalHint.translatesAutoresizingMaskIntoConstraints = false
        labelDeviceApprovalHint.textColor = secondaryTextColor
        labelDeviceApprovalHint.baselineAdjustment = .alignCenters
        labelDeviceApprovalHint.layer.cornerRadius = 2
        labelDeviceApprovalHint.backgroundColor = secondaryBGColor
        labelDeviceApprovalHint.clipsToBounds = true
        return labelDeviceApprovalHint
    }()
    
    
    lazy private var activityIndicator:  UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = secondaryTextColor
        activityIndicator.backgroundColor = secondaryBGColor
        return activityIndicator
    }()
}



