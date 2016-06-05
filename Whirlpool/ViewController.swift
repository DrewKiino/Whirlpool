//
//  ViewController.swift
//  Whirlpool
//
//  Created by Andrew Aquino on 6/4/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  private var chatView: Whirlpool?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    chatView = Whirlpool()
    view.addSubview(chatView!)
    chatView?.fillSuperview(left: 0, right: 0, top: 20, bottom: 0)
    
    chatView?
      .append(Whirlpool.Message(
        text: "Hello, World!",
        username: "Janet Thompson",
        userImageUrl: "http://i1.istockimg.com/file_thumbview_approve/46145816/5/stock-photo-46145816-beauty-in-profile.jpg",
        timestamp: "10:45 AM"
      ))
      .append(Whirlpool.Message(
        text: "Bacon ipsum dolor amet pork pig short ribs salami pork chop alcatra. Bacon picanha t-bone cow frankfurter porchetta ham meatloaf kielbasa spare ribs. Tail pastrami venison boudin, rump andouille ball tip meatball. Turducken ham meatloaf salami beef venison.",
        username: "Grace Macguiver",
        userImageUrl: "http://previews.123rf.com/images/racorn/racorn1308/racorn130805649/21341221-Profile-portrait-of-a-charming-young-business-woman-being-happy-and-smiling-in-an-office-setting--Stock-Photo.jpg",
        timestamp: "11:10 AM"
      ))
      .append(Whirlpool.Message(text:
        "Bacon ipsum dolor amet jerky pancetta pork tenderloin, drumstick andouille swine porchetta shankle leberkas ball tip ribeye pork chop strip steak corned beef. Hamburger brisket rump meatball. Kevin tenderloin flank turkey. Landjaeger alcatra swine filet mignon, ground round beef ribs cow cupim. Swine venison andouille biltong tongue bresaola ball tip salami shoulder turducken doner chicken. Drumstick tri-tip brisket meatloaf pig pancetta ball tip. \n Turducken cupim strip steak, tenderloin bresaola sausage shankle beef tail. Salami tongue bresaola, drumstick tri-tip frankfurter pastrami sausage. Chuck doner filet mignon, brisket kevin kielbasa pig flank. Ham venison frankfurter biltong. \n Chuck pastrami filet mignon ribeye flank ham boudin shoulder. Ribeye turducken boudin, meatloaf pork chop shankle sausage picanha tongue salami rump brisket. Pork chop cow pork short loin venison shank ball tip. Short ribs tail picanha fatback, tenderloin bacon chicken prosciutto rump pancetta ground round leberkas sirloin flank doner. Ribeye meatball shankle, jerky short loin pancetta pork belly beef ribs. Beef ribs turkey ball tip pork chop sirloin, cupim pork belly pastrami. Fatback drumstick ham hock prosciutto frankfurter. \n Meatball cupim pork belly spare ribs. Kevin shankle bresaola, leberkas sirloin bacon sausage tenderloin porchetta ribeye ball tip pancetta frankfurter doner. Short ribs pancetta picanha drumstick tri-tip, swine bacon prosciutto boudin sausage. Sirloin tenderloin frankfurter ham strip steak, short ribs kielbasa jerky andouille. Jowl short loin boudin tail prosciutto ground round landjaeger leberkas. Frankfurter spare ribs beef ribs venison porchetta, shankle drumstick pastrami tri-tip turducken pork loin. Corned beef swine sirloin bacon, ball tip meatloaf meatball venison shoulder tail cupim t-bone. \n Ground round sirloin leberkas, frankfurter jowl rump biltong jerky bacon porchetta kielbasa short loin. Ham hock pancetta ground round alcatra, capicola tenderloin swine chuck pig chicken cow. Sirloin pig shoulder, pork chop alcatra kevin beef pancetta strip steak short ribs tail prosciutto capicola venison tongue. Filet mignon porchetta doner jerky bacon bresaola jowl. Beef ribs drumstick short loin ham t-bone jerky. Beef ribs meatloaf jowl shoulder, cow salami turkey ham t-bone pastrami frankfurter pork loin picanha. Meatball porchetta kevin ground round bacon pork chop biltong.",
        username: "Bob Dylan",
        userImageUrl: "http://img08.deviantart.net/9d6c/i/2012/253/4/d/2012_id_by_density_stock-d5e8sph.jpg",
        timestamp: "3:00 PM"
      ))
      .reload()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

