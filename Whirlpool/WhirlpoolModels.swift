//
//  WhirlpoolModels.swift
//  Whirlpool
//
//  Created by Andrew Aquino on 6/7/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit

public struct WhirlpoolModels {
  
  public class User {
    
    public var username: String?
    public var userImageUrl: String?
    
    public init(username: String?, userImageUrl: String?) {
      self.username = username
      self.userImageUrl = userImageUrl
      
    }
  }
  
  public class Message {
    
    public var session_id: String?
    
    public var message_id: String?
    public var text: String?
    public var username: String?
    public var userImageUrl: String?
    public var timestamp: String?
    public var room: String?
    
    public var pending: Bool = false
    
    public init(
      text: String?,
      username: String?,
      userImageUrl: String?,
      timestamp: String? = nil,
      message_id: String? = nil,
      session_id: String? = nil,
      room: String? = nil
    ) {
      self.text = text
      self.userImageUrl = userImageUrl
      self.username = username
      self.timestamp = timestamp ?? NSDate().toString(.ISO8601Format(.Full))
      self.message_id = message_id ?? abs(NSDate().hashValue).description
      self.session_id = session_id ?? UIDevice.currentDevice().identifierForVendor?.UUIDString ?? nil
      self.room = room
    }
    
    public func toJSON() -> [String: AnyObject] {
      let message_id: String = self.message_id ?? ""
      let text: String = self.text ?? ""
      let username: String = self.username ?? ""
      let userImageUrl: String = self.userImageUrl ?? ""
      let timestamp: String = self.timestamp ?? NSDate().toString(.ISO8601Format(.Full)) ?? ""
      let session_id: String = self.session_id ?? ""
      let room: String = self.room ?? ""
      return [
        "message_id": message_id,
        "text": text,
        "username": username,
        "userImageUrl": userImageUrl,
        "timestamp": timestamp,
        "session_id": session_id,
        "room": room
        ] as [String: AnyObject]
    }
  }
  
  public class MessageCell: UITableViewCell {
    
    public var containerView: UIView?
    
    public var usernameLabel: UILabel?
    public var userImageView: UIImageView?
    public var timestampLabel: UILabel?
    public var textView: UITextView?
    
    public var userImageUrl: String?
    
    public var isConsecutiveMessage: Bool = false
    public var isLastConsecutiveMessage: Bool = false
    public var isLastMessage: Bool = false
    
    private override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
    }
    
    public override func layoutSubviews() {
      super.layoutSubviews()
      
      containerView?.fillSuperview(left: 8, right: 8, top: 4, bottom: 4)
      containerView?.layer.shadowColor = UIColor.blackColor().CGColor
      containerView?.layer.shadowOpacity = 0.05
      containerView?.layer.shadowOffset = CGSizeMake(-2, 3)
      containerView?.layer.shadowRadius = 1.0
      containerView?.layer.masksToBounds = false
      
      usernameLabel?.hidden = isConsecutiveMessage
      userImageView?.hidden = isConsecutiveMessage
      timestampLabel?.hidden = !isLastConsecutiveMessage && isConsecutiveMessage && !isLastMessage
      
      if isConsecutiveMessage {
        
        timestampLabel?.anchorInCorner(.TopRight, xPad: 8, yPad: 8, width: timestampLabel?.text?.width(24) ?? 0, height: 24)
        textView?.alignAndFill(align: .ToTheLeftMatchingTop, relativeTo: timestampLabel!, padding: 8)
        
      } else {
        
        userImageView?.anchorInCorner(.TopLeft, xPad: 8, yPad: 8, width: 24, height: 24)
        userImageView?.backgroundColor = .clearColor()
        
        timestampLabel?.anchorInCorner(.TopRight, xPad: 8, yPad: 8, width: timestampLabel?.text?.width(24) ?? 0, height: 24)
        
        usernameLabel?.alignBetweenHorizontal(align: .ToTheRightCentered, primaryView: userImageView!, secondaryView: timestampLabel!, padding: 8, height: 24)
        
        textView?.alignAndFillWidth(
          align: .UnderMatchingLeft,
          relativeTo: userImageView!,
          padding: 4,
          height: (textView?.text.height(containerView?.frame.width ?? frame.width) ?? 0) + 8
        )
        
        userImageView?.imageFromUrl(userImageUrl, maskWithEllipse: true)
      }
    }
    
    private func setup() {
      
      backgroundColor = .clearColor()
      
      containerView = UIView()
      containerView?.backgroundColor = .whiteColor()
      addSubview(containerView!)
      
      containerView?.layer.cornerRadius = 2.0
      containerView?.layer.masksToBounds = true
      
      // MARK: setup username label
      usernameLabel = UILabel()
      usernameLabel?.font = UIFont.systemFontOfSize(12)
      usernameLabel?.textAlignment = .Left
      containerView?.addSubview(usernameLabel!)
      
      // MARK: setup timestamp label
      timestampLabel = UILabel()
      timestampLabel?.font = UIFont.systemFontOfSize(10)
      timestampLabel?.textColor = .lightGrayColor()
      timestampLabel?.textAlignment = .Right
      containerView?.addSubview(timestampLabel!)
      
      // MARK: setup user image view
      userImageView = UIImageView()
      containerView?.addSubview(userImageView!)
      
      // MARK: setup text view
      textView = UITextView()
      textView?.backgroundColor = .clearColor()
      textView?.contentInset = UIEdgeInsetsMake(-8.0, -5.0, 0.0, 0.0)
      textView?.font = UIFont.systemFontOfSize(12)
      textView?.editable = false
      textView?.scrollEnabled = false
      textView?.textAlignment = .Left
      containerView?.addSubview(textView!)
    }
  }
}
