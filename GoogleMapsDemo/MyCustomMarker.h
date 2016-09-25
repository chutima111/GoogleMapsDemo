//
//  MyCustomMarker.h
//  GoogleMapsDemo
//
//  Created by Patrick Sanders on 6/21/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomMarker : UIView
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;

@property (weak, nonatomic) NSString *urlString;


@end
