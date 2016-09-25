//
//  MyWebViewViewController.m
//  GoogleMapsDemo
//
//  Created by chutima mungmee on 9/20/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import "MyWebViewViewController.h"

@interface MyWebViewViewController () <UINavigationBarDelegate>

@end

@implementation MyWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    NSString *urlString = self.urlString;
    
    if (urlString == nil) {
        [_myWebView addSubview:_myEmptyImage];
    
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_myWebView loadRequest:request];
    
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBackPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
