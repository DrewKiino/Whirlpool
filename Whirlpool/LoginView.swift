//
//  LoginView.swift
//  Whirlpool
//
//  Created by Andrew Aquino on 6/5/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit
import Neon

public class LoginView: UIViewController, UITextFieldDelegate {
  
  private let input = UITextField()
  private let join = UIButton()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(input)
    
    input.anchorInCenter(width: 256, height: 24)
    input.delegate = self
    input.font = UIFont.systemFontOfSize(12)
    input.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
    input.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
    input.layer.borderWidth = 0.5
    input.layer.cornerRadius = 5.0
    
    view.addSubview(join)
    
    
    join.align(.UnderCentered, relativeTo: input, padding: 8, width: 64, height: 24)
    join.setTitle("Join", forState: .Normal)
    join.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
    join.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.5), forState: .Highlighted)
    join.addTarget(self, action: "joinPressed", forControlEvents: .TouchUpInside)
  }
  
  public func joinPressed() {
    
    let chatView = UIViewController()
    chatView.view.backgroundColor = .whiteColor()
    chatView.view.addSubview(Whirlpool.ChatView(
      user:
        WhirlpoolModels.User(username: "Rob", userImageUrl: "http://zblogged.com/wp-content/uploads/2015/11/17.jpg"),
//        WhirlpoolModels.User(username: "Andrew", userImageUrl: "http://totemv.com/drewkiino.github.io/img/selfie-car.jpeg"),
//        WhirlpoolModels.User(username: "Macie", userImageUrl: "https://assets.entrepreneur.com/content/16x9/822/20150406145944-dos-donts-taking-perfect-linkedin-profile-picture-selfie-mobile-camera-2.jpeg"),
      room: input.text?.isEmpty == true ? "CoolRoom" : input.text ?? "CoolRoom"
    ))
    
    navigationController?.navigationBar.translucent = false
    navigationController?.pushViewController(chatView, animated: true)
//    presentViewController(chatView!, animated: true, completion: nil)
  }
}
