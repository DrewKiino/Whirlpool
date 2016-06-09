//
//  WhirlpoolModels.swift
//  Whirlpool
//
//  Created by Andrew Aquino on 6/7/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit
import Pacific
import Async

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
    
    public var userImageUrl: String?
    
    public var isConsecutiveMessage: Bool = false
    public var isLastConsecutiveMessage: Bool = false
    public var isLastMessage: Bool = false
    
    public var message: WhirlpoolModels.Message?
    
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
      
      timestampLabel?.anchorInCorner(.TopRight, xPad: 8, yPad: 8, width: 48, height: 48)
      timestampLabel?.frame.origin.y -= 17
      
      containerView?.fillSuperview(left: 8, right: 8, top: 4, bottom: 4)
      
      textLabel?.frame = CGRectMake(16, 8 + (isConsecutiveMessage ? 0 : 32), frame.width - 76, frame.height)
      textLabel?.sizeToFit()
      
      usernameLabel?.hidden = isConsecutiveMessage
      userImageView?.hidden = isConsecutiveMessage
      
      if !isLastConsecutiveMessage && isConsecutiveMessage && !isLastMessage {
        
        let textViewWidth: CGFloat = max((textLabel?.text?.width(frame.height) ?? 0) + 16, 20)
        let threshold: Bool = textViewWidth > (timestampLabel?.frame.origin.x ?? 0)
        let thresholdWidth: CGFloat = (threshold ? (containerView?.frame.width ?? 0) - (timestampLabel?.frame.width ?? 0) : textViewWidth)
        
        containerView?.anchorAndFillEdge(.Left, xPad: 8, yPad: 4, otherSize: min(textViewWidth, thresholdWidth))
        
      } else if isConsecutiveMessage {
        
        let textViewWidth: CGFloat = max((textLabel?.text?.width(frame.height) ?? 0) + 16, 20)
        let threshold: Bool = textViewWidth > (timestampLabel?.frame.origin.x ?? 0)
        let thresholdWidth: CGFloat = (threshold ? (containerView?.frame.width ?? 0) - (timestampLabel?.frame.width ?? 0) : textViewWidth)
        
        containerView?.anchorAndFillEdge(.Left, xPad: 8, yPad: 4, otherSize: min(textViewWidth, thresholdWidth))
        
      } else {
        
        userImageView?.anchorInCorner(.TopLeft, xPad: 8, yPad: 8, width: 24, height: 24)
        userImageView?.backgroundColor = .clearColor()
        
        usernameLabel?.alignAndFillWidth(align: .ToTheRightCentered, relativeTo: userImageView!, padding: 4, height: 24)
        
        let textViewWidth: CGFloat = (textLabel?.frame.width ?? 0) + 12
        let userImageViewWidth: CGFloat = (userImageView?.frame.width ?? 0) + 24
        
        let usernameLabelWidth: CGFloat = (usernameLabel?.text?.width(24) ?? 0)
        
        containerView?.anchorAndFillEdge(.Left, xPad: 8, yPad: 4, otherSize: max(userImageViewWidth + usernameLabelWidth, textViewWidth))
        
        userImageView?.imageFromUrl(userImageUrl, maskWithEllipse: true)
      }
    }
    
    private func setup() {
      
      backgroundColor = .clearColor()
      
      containerView = UIView()
      containerView?.backgroundColor = .whiteColor()
      addSubview(containerView!)
      
      containerView?.layer.cornerRadius = 12.0
      containerView?.layer.masksToBounds = true
      
      // MARK: setup username label
      usernameLabel = UILabel()
      usernameLabel?.font = UIFont.boldSystemFontOfSize(12)
      usernameLabel?.textAlignment = .Left
      containerView?.addSubview(usernameLabel!)
      
      // MARK: setup timestamp label
      timestampLabel = UILabel()
      timestampLabel?.font = UIFont.systemFontOfSize(10)
      timestampLabel?.textColor = .lightGrayColor()
      timestampLabel?.textAlignment = .Right
      timestampLabel?.numberOfLines = 2
      addSubview(timestampLabel!)
//      containerView?.addSubview(timestampLabel!)
      
      // MARK: setup user image view
      userImageView = UIImageView()
      containerView?.addSubview(userImageView!)
      
      // MARK: setup text label
      textLabel?.backgroundColor = .clearColor()
      textLabel?.numberOfLines = 0
      textLabel?.font = UIFont.systemFontOfSize(12)
      addSubview(textLabel!)
      
      layer.masksToBounds = false
    }
  }
}
