//
//  Whirlpool.swift
//  Whirlpool
//
//  Created by Andrew Aquino on 6/4/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit
import Neon
import Pacific
import Tide
import Storm
import SwiftDate
import Async
import UIColor_Hex_Swift
import SwiftyTimer

// Whirlpool Chat Framework
public struct Whirlpool {
  
  // convenient config vars that affect the entire class settings
  public struct Config {
    public static var skip: Int = 0
    public static var paging: Int = 30
    public static var font: UIFont = UIFont.systemFontOfSize(14)
  }
  
  public class ChatView: BasicView, UITableViewDelegate, UITableViewDataSource {
    
    // dynamic vars
    private var keyboardHeight: CGFloat = 0
    
    // MVC
    private let controller = Controller()
    private var model: Model { get { return controller.model } }
    
    // views
    private var tableView: UITableView?
    private var refreshControl: UIRefreshControl?
    private var inputContainer: InputContainer?
    
    public convenience init(
      user: WhirlpoolModels.User?,
      room: String? = nil
      ) {
        self.init()
        
        model.username = user?.username
        model.userImageUrl = user?.userImageUrl
        model.room = room?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        setup()
    }
    
    public convenience init(
      username: String,
      userImageUrl: String,
      room: String? = nil
    ) {
      self.init()
      
      model.username = username
      model.userImageUrl = userImageUrl
      model.room = room?.stringByReplacingOccurrencesOfString(" ", withString: "")
      
      setup()
    }
    
    public override func setup() {
      
      backgroundColor = .whiteColor()
      
      // setup controller
      controller.setup()
      controller.layoutViewsBlock = { [weak self] keyboardHeight in
        self?.keyboardHeight = keyboardHeight
        if self?.tableView?.contentSize.height > self?.tableView?.frame.height {
          self?.layoutSubviews()
        }
      }
      controller.keyboardDidShowBlock = { [weak self] in
        self?.scrollToMostRecent()
      }
      controller.receivedMessageBlock = { [weak self] scroll, invertScroll in
        self?.simulateReceivedMessage(scroll, invertScroll: invertScroll, animated: false)
        log.info("message received")
      }
      controller.sendPendingBlock = { [weak self] message_id in
        if let message = (self?.model.messages.filter { $0.message_id == message_id })?.first {
          message.pending = true
          message.hidden = true
        }
        self?.simulateReceivedMessage(animated: true)
        log.info(("message sent pending"))
        NSTimer.after(10.0) { [weak self] in
          if let message = (self?.model.messages.filter { $0.message_id == message_id })?.first where message.pending == true {
            message.hidden = false
            self?.simulateReceivedMessage(animated: false)
            log.warning("message still pending")
          }
        }
      }
      controller.sendSuccessfulBlock = { [weak self] message_id in
        NSTimer.after(0.2) { [weak self] in
          if let message = (self?.model.messages.filter { $0.message_id == message_id })?.first {
            message.pending = false
            message.hidden = false
          }
          self?.simulateReceivedMessage(animated: false)
          log.info("message sent success")
        }
      }
      controller.didConnectToServer = { [weak self] in
        self?.inputContainer?.enableSendButton()
      }
      
      // setup table view
      tableView = UITableView()
      tableView?.separatorColor = .clearColor()
      tableView?.delegate = self
      tableView?.dataSource = self
      tableView?.estimatedRowHeight = 36
      tableView?.rowHeight = UITableViewAutomaticDimension
      tableView?.layer.masksToBounds = false
      tableView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
      tableView?.registerClass(WhirlpoolModels.MessageCell.self, forCellReuseIdentifier: "MessageCell")
      addSubview(tableView!)
      
      // setup refresh control
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
      tableView?.addSubview(refreshControl!)
      
      // setup input container
      inputContainer = InputContainer()
      inputContainer?.disableSendButton()
      inputContainer?.hidden = true
      inputContainer?.backgroundColor = .whiteColor()
      inputContainer?.textFieldDidBeginEditingBlock = { [weak self] in
      }
      inputContainer?.textFieldDidEndEditingBlock = { [weak self] in
      }
      inputContainer?.sendButtonOnPressBlock = { [weak self] button, text in
        self?.controller.sendMessage(WhirlpoolModels.Message(
          text: text,
          username: self?.model.username,
          userImageUrl: self?.model.userImageUrl,
          session_id: self?.model.session_id,
          room: self?.model.room
        ))
      }
      
      addSubview(inputContainer!)
    }
    
    // setup layout
    
    public override func layoutSubviews() {
      super.layoutSubviews()
      
      
      fillSuperview(left: 0, right: 0, top: 4, bottom: 0)
      
      inputContainer?.hidden = false
      inputContainer?.anchorToEdge(
        .Bottom,
        padding: keyboardHeight,
        width: frame.width,
        height: 48
      )
      
      tableView?.alignAndFill(align: .AboveCentered, relativeTo: inputContainer!, padding: 0)
      
      inputContainer?.layer.shadowColor = UIColor.blackColor().CGColor
      inputContainer?.layer.shadowOpacity = 0.05
      inputContainer?.layer.shadowOffset = CGSizeMake(0, -1)
      inputContainer?.layer.shadowRadius = 1.0
      inputContainer?.layer.masksToBounds = false
    }
    
    public func dismissKeyboard() {
      inputContainer?.inputTextField?.resignFirstResponder()
    }
    
    // MARK: class methods
    
    public func append(message: WhirlpoolModels.Message) -> Self {
      model.messages.insert(message, atIndex: 0)
      return self
    }
    
    public func reload() -> Self {
      tableView?.reloadData()
      return self
    }
    
    public func simulateReceivedMessage(scroll: Bool = true, invertScroll: Bool = false, animated: Bool = true, delay: Double = 0.0) {
      reload()
      refreshControl?.endRefreshing()
      if invertScroll && scroll {
        scrollToMostLatest(animated, delay: delay)
      } else if scroll {
        scrollToMostRecent(animated, delay: delay)
      }
    }
    
    public func scrollToMostLatest(animated: Bool = true, delay: Double = 0.0) {
      if model.messages.isEmpty { return }
      if delay > 0 {
        NSTimer.after(delay) { [weak self] in
          self?.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: animated)
        }
      } else {
        tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: animated)
      }
    }
    
    public func scrollToMostRecent(animated: Bool = true, delay: Double = 0.0) {
      if model.messages.isEmpty { return }
      if delay > 0 {
        NSTimer.after(delay) { [weak self] in
          self?.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: (self?.model.messages.count ?? 1) - 1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
      } else {
        tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: model.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
      }
    }
    
    
    private func getBubbleColor(indexPath: NSIndexPath) -> UIColor {
      return model.messages[indexPath.row].username == model.username
        ? UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 0.1)
        : UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 0.1)
    }
    
    private func updateTimestampUI(cell: WhirlpoolModels.MessageCell, indexPath: NSIndexPath) {
      
      cell.timestampLabel?.hidden = false
      
      if let messageDate: NSDate = model.messages[indexPath.row].timestamp?.toDateFromISO8601()
        where model.messages.count > 1 && indexPath.row + 1 < model.messages.count
      {
        if let futureMessageDate: NSDate = model.messages[indexPath.row + 1].timestamp?.toDateFromISO8601() {
          cell.timestampLabel?.hidden = true
          if futureMessageDate - 1.minutes > messageDate {
            cell.timestampLabel?.hidden = false
            cell.timestampLabel?.text = model.messages[indexPath.row].timestamp?.toDateFromISO8601()?
              .toSimpleString(!messageDate.isInToday() ? .ShortStyle : .NoStyle, timeStyle: .ShortStyle)
          }
        }
      }
      
      if indexPath.row == 0 {
        cell.timestampLabel?.hidden = false
      }
    }
    
    private func isConsecutiveMessage(indexPath: NSIndexPath) -> Bool {
      if model.messages.count > 1 && indexPath.row > 0 {
        return model.messages[indexPath.row].username == model.messages[indexPath.row - 1].username
      }
      return false
    }
    
    private func isLastConsecutiveMessage(indexPath: NSIndexPath) -> Bool {
      if model.messages.count > 1 && indexPath.row < model.messages.count - 1 {
        return model.messages[indexPath.row].username != model.messages[indexPath.row + 1].username
      }
      return false
    }
    
    public func refresh(sender: UIRefreshControl) {
      controller.getMessages(model.messages.count, paging: Whirlpool.Config.paging, invertScroll: true)
    }
    
    // MARK: Tableview methods
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if !model.messages.isEmpty {
        let height: CGFloat = model.messages[indexPath.row].text?.height(frame.width - 128) ?? 0
        if isConsecutiveMessage(indexPath) {
          return height < 36 ? height - 1 : height + 3
        } else {
          return max(height + (height > 36 ? 36 : 33), 64)
//          return max(height + (indexPath.row == 0 && height > 36 ? 36 : 33), 64)
        }
      }
      return 64
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return model.messages.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as? WhirlpoolModels.MessageCell
        where !model.messages.isEmpty
      {
        
        cell.message = model.messages[indexPath.row]
        
        cell.textLabel?.text = model.messages[indexPath.row].text
        cell.usernameLabel?.text = model.messages[indexPath.row].username
        cell.userImageUrl = model.messages[indexPath.row].userImageUrl
        cell.timestampLabel?.text = model.messages[indexPath.row].timestamp?.toDateFromISO8601()?.toSimpleString()
        
        cell.containerView?.backgroundColor = getBubbleColor(indexPath)
        
        cell.isConsecutiveMessage = isConsecutiveMessage(indexPath)
        cell.isLastConsecutiveMessage = isLastConsecutiveMessage(indexPath)
        cell.isLastMessage = model.messages.count - 1 == indexPath.row
        
        updateTimestampUI(cell, indexPath: indexPath)
        
        cell.hidden = cell.message?.hidden == true
        
        return cell
      }
      return UITableViewCell()
    }
    
    // MARK: Controller
    
    public class Controller: NSObject {
      
      public let model = Model()
      
      private var socket: Socket?
      
      private var keyboardDidShowBlock: (() -> Void)?
      private var layoutViewsBlock: ((keyboardHeight: CGFloat) -> Void)?
      private var receivedMessageBlock: ((scroll: Bool, invertScroll: Bool) -> Void)?
      private var sendSuccessfulBlock: ((message_id: String?) -> Void)?
      private var sendPendingBlock: ((message_id: String?) -> Void)?
      private var didConnectToServer: (() -> Void)?
      
      public override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
      }
      
      private func setup() {
        
        // setup sockets
        
        socket = Socket(room: model.room)
        
        socket?.on("chat.message.fromServer") { [weak self] json in
          if json["session_id"].string == self?.model.session_id
            || json["session_id"].string == UIDevice.currentDevice().identifierForVendor?.UUIDString
          {
            return
          }
          let message = WhirlpoolModels.Message(
            text: json["text"].string,
            username: json["username"].string,
            userImageUrl: json["userImageUrl"].string,
            timestamp: json["timestamp"].string,
            message_id: json["message_id"].string,
            session_id: json["session_id"].string,
            room: json["room"].string
          )
          self?.model.messages.append(message)
          self?.receivedMessageBlock?(scroll: true, invertScroll: false)
        }
        
        socket?.on("chat.message.response") { [weak self] json in
          if json["status"].int == 200 {
            self?.sendSuccessfulBlock?(message_id: json["message_id"].string)
          }
        }
        
        socket?.on("chat.join.response") { [weak self] json in
          if let room = json["room"].string {
            log.info("joined room: \(room)")
          }
        }
        
        socket?.onConnect("Whirlpool.Controller") { [weak self] in
          self?.model.messages.removeAll(keepCapacity: false)
          self?.getMessages() { [weak self] in
            self?.model.session_id = self?.socket?.session_id
            self?.model.pendingMessages.forEach { [weak self] message in
              self?.socket?.emit("chat.message", objects: message.toJSON(), forceConnection: false)
            }
            self?.model.pendingMessages.removeAll(keepCapacity: false)
            self?.didConnectToServer?()
          }
        }
        
        socket?.connect()
      }
      
      // make sure we remove observers!
      
      deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self)
        
        if socket?.isConnected() == true {
          socket?.disconnect()
        }
        socket = nil
      }
      
      // MARK: keyboard observers
      
      public func keyboardDidShow(notification: NSNotification) {
        keyboardDidShowBlock?()
      }
      
      public func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as? NSDictionary {
          layoutViewsBlock?(keyboardHeight: userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.height ?? 0)
        }
      }
      
      public func keyboardWillHide(notification: NSNotification) {
        layoutViewsBlock?(keyboardHeight: 0)
      }
      
      public func sendMessage(message: WhirlpoolModels.Message) {
        if socket?.isConnected() == false {
          model.pendingMessages.append(message)
        } else {
          socket?.emit("chat.message", objects: message.toJSON())
        }
        model.messages.append(message)
        sendPendingBlock?(message_id: message.message_id)
      }
      
      public func getMessages(skip: Int = Whirlpool.Config.skip, paging: Int = Whirlpool.Config.paging, invertScroll: Bool = false, completionHandler: (() -> Void)? = nil) {
        let room: String = model.room ?? ""
        App.GET("/chat/getMessages?room=\(room)&skip=\(skip)&paging=\(paging)") { [weak self] json, error in
          if let array = json?.array {
            array.forEach { [weak self] json in
              let message = WhirlpoolModels.Message(
                text: json["text"].string,
                username: json["username"].string,
                userImageUrl: json["userImageUrl"].string,
                timestamp: json["timestamp"].string,
                message_id: json["message_id"].string,
                session_id: json["session_id"].string,
                room: json["room"].string
              )
              self?.model.messages.insert(message, atIndex: 0)
            }
            self?.receivedMessageBlock?(scroll: true, invertScroll: invertScroll)
          }
          completionHandler?()
        }
      }
    }
    
    public class Model {
      
      public var users: [WhirlpoolModels.User] = []
      
      private var username: String?
      private var userImageUrl: String?
      
      private var room: String?
      private var session_id: String?
      
      private var messages: [WhirlpoolModels.Message] = []
      private var pendingMessages: [WhirlpoolModels.Message] = []
    }
    
    //
    
    internal class InputContainer: BasicView, UITextFieldDelegate {
      
      private var originalFrame: CGRect?
      
      private var inputTextField: UITextField?
      private var sendButton: UIButton?
      
      private var textFieldDidBeginEditingBlock: (() -> Void)?
      private var textFieldDidEndEditingBlock: (() -> Void)?
      private var sendButtonOnPressBlock: ((sender: UIButton, text: String?) -> Void)?
      
      internal override func setup() {
        super.setup()
        
        inputTextField = UITextField()
        inputTextField?.delegate = self
        inputTextField?.font = Whirlpool.Config.font
        inputTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        inputTextField?.layer.borderColor = UIColor(white: 0, alpha: 0.5).CGColor
        inputTextField?.layer.borderWidth = 0.5
        inputTextField?.layer.cornerRadius = 5.0
        addSubview(inputTextField!)
        
        sendButton = UIButton()
        sendButton?.setTitle("Send", forState: .Normal)
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.5), forState: .Highlighted)
        sendButton?.addTarget(self, action: "sendButtonPressed:", forControlEvents: .TouchUpInside)
        addSubview(sendButton!)
      }
      
      internal override func layoutSubviews() {
        super.layoutSubviews()
        
        originalFrame = frame
        
        sendButton?.anchorToEdge(.Right, padding: 8, width: 48, height: 24)
        inputTextField?.alignAndFillWidth(align: .ToTheLeftCentered, relativeTo: sendButton!, padding: 8, height: 24)
      }
      
      internal func sendButtonPressed(sender: UIButton) {
        if inputTextField?.text?.isEmpty == true { return }
        sendButtonOnPressBlock?(sender: sender, text: inputTextField?.text)
        inputTextField?.text = nil
      }
      
      internal func disableSendButton() {
        sendButton?.userInteractionEnabled = false
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Highlighted)
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.5), forState: .Normal)
      }
      
      internal func enableSendButton() {
        sendButton?.userInteractionEnabled = true
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
        sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.5), forState: .Highlighted)
      }
      
      // MARK: textfield methods
      
      internal func textFieldDidBeginEditing(textField: UITextField) {
        textFieldDidBeginEditingBlock?()
      }
      
      internal func textFieldDidEndEditing(textField: UITextField) {
        textFieldDidEndEditingBlock?()
      }
    }
  }
}

// Convenient subclasses

public class BasicView: UIView {
  
  public init() {
    super.init(frame: CGRectZero)
    setup()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  public func setup() {}
}

// utility extensions

extension NSDate {
  
  public func toSimpleString(dateStyle: NSDateFormatterStyle = .ShortStyle, timeStyle: NSDateFormatterStyle = .ShortStyle) -> String? {
    if self >= NSDate() - 60.seconds {
      return "Just Now"
    } else if let dateString = toString(
      dateStyle: dateStyle,
      timeStyle: timeStyle,
      inRegion: DateRegion(),
      relative: true
    ) {
      if isInToday() {
        return dateString.stringByReplacingOccurrencesOfString("Today, ", withString: "")
      } else {
        return dateString.stringByReplacingOccurrencesOfString(", ", withString: " ")
      }
    }
    return nil
  }
}








