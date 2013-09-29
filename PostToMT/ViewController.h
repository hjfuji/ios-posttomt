//
//  ViewController.h
//  PostToMT
//
//  Created by hajime fujimoto on 2013/09/18.
//  Copyright (c) 2013年 Hajime Fujimoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
-(void) showMessage:(NSString*) title
            message:(NSString*) msg;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvwBody;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@end
