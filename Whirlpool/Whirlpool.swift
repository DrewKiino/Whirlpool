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
import SDWebImage
import Tide
import SDWebImage

public class Whirlpool: BasicView, UITableViewDelegate, UITableViewDataSource {
  
  // dynamic vars
  private var keyboardHeight: CGFloat = 0
  
  // MVC
  private let controller = Controller()
  private let model = Model()
  
  // views
  private var tableView: UITableView?
  private var inputContainer: InputContainer?
  
  public override func setup() {
    
    // setup controller
    controller.layoutViewsBlock = { [weak self] keyboardHeight in
      self?.keyboardHeight = keyboardHeight
      self?.layoutSubviews()
    }
    
    // Setup table view
    tableView = UITableView()
    tableView?.separatorColor = .clearColor()
    tableView?.delegate = self
    tableView?.dataSource = self
    tableView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    tableView?.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    addSubview(tableView!)
    
    inputContainer = InputContainer()
    inputContainer?.backgroundColor = .whiteColor()
    inputContainer?.textFieldDidBeginEditingBlock = { [weak self] in
    }
    inputContainer?.textFieldDidEndEditingBlock = { [weak self] in
      
    }
    addSubview(inputContainer!)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    inputContainer?.anchorToEdge(.Bottom, padding: keyboardHeight, width: frame.width, height: 48)
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
  
  public func append(message: Message) -> Self {
    model.messages.append(message)
    return self
  }
  
  public func reload() -> Self {
    tableView?.reloadData()
    return self
  }
  
  // MARK: Tableview methods
  
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if let height = model.messages[indexPath.row].text?.height(frame.width - 16) {
      return max(64, height + 40)
    } else {
      return 64
    }
  }
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.messages.count
  }
  
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as? MessageCell {
      
      cell.textView?.text = model.messages[indexPath.row].text
      cell.usernameLabel?.text = model.messages[indexPath.row].username
      cell.userImageUrl = model.messages[indexPath.row].userImageUrl
      cell.timestampLabel?.text = model.messages[indexPath.row].timestamp
      cell.containerView?.backgroundColor = .whiteColor()
//      cell.containerView?.backgroundColor = indexPath.row % 2 == 0 ? .greenColor() : .yellowColor()
      
      return cell
    }
    return UITableViewCell()
  }
  
  // MARK: classes
  
  public class Message {
    
    public var text: String?
    public var username: String?
    public var userImageUrl: String?
    public var timestamp: String?
    
    public init(text: String?, username: String?, userImageUrl: String?, timestamp: String?) {
      self.text = text
      self.userImageUrl = userImageUrl
      self.username = username
      self.timestamp = timestamp
    }
  }
  
  public class Controller: NSObject {
    
    private var layoutViewsBlock: ((keyboardHeight: CGFloat) -> Void)?
    
    public override init() {
      super.init()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
      NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self)
      NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self)
    }
    
    
    public func keyboardWillShow(notification: NSNotification) {
      if let userInfo = notification.userInfo as? NSDictionary {
        layoutViewsBlock?(keyboardHeight: userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.height ?? 0)
      }
    }
    
    public func keyboardWillHide(notification: NSNotification) {
      layoutViewsBlock?(keyboardHeight: 0)
    }
  }
  
  public class Model {
    private var messages: [Message] = []
  }
  
  private class MessageCell: UITableViewCell {
    
    private var containerView: UIView?
    
    private var usernameLabel: UILabel?
    private var userImageView: UIImageView?
    private var timestampLabel: UILabel?
    private var textView: UITextView?
    
    private var userImageUrl: String?
    
    private override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
    }
    
    private required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setup()
    }
    
    private override func layoutSubviews() {
      super.layoutSubviews()
      
      containerView?.fillSuperview(left: 8, right: 8, top: 4, bottom: 4)
      containerView?.layer.shadowColor = UIColor.blackColor().CGColor
      containerView?.layer.shadowOpacity = 0.05
      containerView?.layer.shadowOffset = CGSizeMake(-2, 3)
      containerView?.layer.shadowRadius = 1.0
      containerView?.layer.masksToBounds = false
      
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
      containerView?.addSubview(usernameLabel!)
      
      // MARK: setup timestamp label
      timestampLabel = UILabel()
      timestampLabel?.font = UIFont.systemFontOfSize(12)
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
//      textView?.backgroundColor = .blueColor()
      textView?.textAlignment = .Left
      containerView?.addSubview(textView!)
    }
  }
  
  public class InputContainer: BasicView, UITextFieldDelegate {
    
    private var originalFrame: CGRect?
    
    private var inputTextField: UITextField?
    private var sendButton: UIButton?
    
    private var textFieldDidBeginEditingBlock: (() -> Void)?
    private var textFieldDidEndEditingBlock: (() -> Void)?
    
    public override func setup() {
      super.setup()
      
      inputTextField = UITextField()
      inputTextField?.delegate = self
      inputTextField?.font = UIFont.systemFontOfSize(12)
      inputTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
      inputTextField?.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
      inputTextField?.layer.borderWidth = 0.5
      inputTextField?.layer.cornerRadius = 5.0
      addSubview(inputTextField!)
      
      sendButton = UIButton()
      sendButton?.setTitle("Send", forState: .Normal)
      sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), forState: .Normal)
      sendButton?.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.5), forState: .Highlighted)
      addSubview(sendButton!)
    }
    
    public override func layoutSubviews() {
      super.layoutSubviews()
      
      originalFrame = frame
      
      sendButton?.anchorToEdge(.Right, padding: 8, width: 48, height: 24)
      inputTextField?.alignAndFillWidth(align: .ToTheLeftCentered, relativeTo: sendButton!, padding: 8, height: 24)
    }
    
    // MARK: textfield methods
    
    public func textFieldDidBeginEditing(textField: UITextField) {
      textFieldDidBeginEditingBlock?()
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
      textFieldDidEndEditingBlock?()
    }
  }
}

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

extension String {
  
  func height(width: CGFloat, font: UIFont = UIFont.systemFontOfSize(12)) -> CGFloat{
    let height = self.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options:
      NSStringDrawingOptions.UsesLineFragmentOrigin,
      attributes: [
        NSFontAttributeName: font
      ],
      context: nil
    ).height
    return height > 24 ? height * 1.12 : height
    // WHY add a modifier? because at large texts, textview height will always return the height minus some lines 
    // for some reason, so we compensate by adding the height of line which justly estimates around this number
  }
  
  func width(height: CGFloat, font: UIFont = UIFont.systemFontOfSize(12)) -> CGFloat {
    let width = self.boundingRectWithSize(CGSize(width: CGFloat.max, height: height), options:
      NSStringDrawingOptions.UsesLineFragmentOrigin,
      attributes: [
        NSFontAttributeName: font
      ],
      context: nil
      ).width
    return width
    // WHY add a modifier? because at large texts, textview height will always return the height minus some lines
    // for some reason, so we compensate by adding the height of line which justly estimates around this number
  }
}

extension UIImageView {
  
  public func imageFromUrl (
    url: String?,
    placeholder: UIImage? = nil,
    maskWithEllipse: Bool = false,
    block: ((image: UIImage?) -> Void)? = nil)
  {
    if let url = url, let nsurl = NSURL(string: url) {
      // set the tag with the url's unique hash value
      if tag == url.hashValue { return }
      // else set the new tag as the new url's hash value
      tag = url.hashValue
      image = nil
      // show activity
      showActivityView(nil, width: frame.width, height: frame.height)
      // begin image download
      SDWebImageManager.sharedManager().downloadImageWithURL(nsurl, options: [], progress: { (received: NSInteger, actual: NSInteger) -> Void in
        }) { [weak self] (image, error, cache, finished, nsurl) -> Void in
          block?(image: image)
          if maskWithEllipse {
            self?.fitClip(image) { [weak self] image in self?.rounded(image) }
          } else {
            self?.fitClip(image)
          }
          self?.dismissActivityView()
      }
    } else {
      image = placeholder
      if maskWithEllipse {
        fitClip() { [weak self] image in self?.rounded(image) }
      } else {
        fitClip()
      }
    }
  }
}


extension UIView {
  
  public func showActivityView(heightOffset: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil, style: UIActivityIndicatorViewStyle = .Gray) {
    dismissActivityView()
    var activityView: UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: style)
    activityView.frame = CGRectMake(0, heightOffset ?? 0, width ?? frame.width, height ?? frame.height)
    activityView.tag = 1337
    activityView.startAnimating()
    addSubview(activityView)
    activityView = nil
  }
  
  public func dismissActivityView() {
    for view in subviews {
      if let activityView = view as? UIActivityIndicatorView where activityView.tag == 1337 {
        activityView.stopAnimating()
        activityView.removeFromSuperview()
      }
    }
  }
}












