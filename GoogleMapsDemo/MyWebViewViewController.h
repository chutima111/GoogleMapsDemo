//
//  MyWebViewViewController.h
//  GoogleMapsDemo
//
//  Created by chutima mungmee on 9/20/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWebViewViewController : UIViewController

@property (nonatomic, strong) NSString *urlString;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
- (IBAction)btnBackPressed:(id)sender;

@end
