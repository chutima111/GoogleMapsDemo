//
//  ViewController.m
//  GoogleMapsDemo
//
//  Created by Patrick Sanders on 6/21/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import "ViewController.h"
#import "MyCustomMarker.h"
#import "MyWebViewViewController.h"
@import GoogleMaps;

@interface ViewController () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                        longitude:151.20
                                                                 zoom:12.5];
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.camera = camera;
    self.mapView_.delegate = self;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView_;
    marker.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(-33.872576, 151.243864);
    marker2.title = @"Boats";
    marker2.snippet = @"In the harbor";
    marker2.map = self.mapView_;
    marker2.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = CLLocationCoordinate2DMake(-33.843248, 151.241889);
    marker3.title = @"Taronga Zoo";
    marker3.snippet = @"Animals!";
    marker3.map = self.mapView_;
    marker3.infoWindowAnchor = CGPointMake(0.5, -0.25);

    
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    
    NSUInteger selectedMapType = sender.selectedSegmentIndex;
    
    switch (selectedMapType) {
        case 0:
            self.mapView_.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView_.mapType = kGMSTypeHybrid;
            break;
        case 2:
            self.mapView_.mapType = kGMSTypeSatellite;
            break;
            
        default:
            self.mapView_.mapType = kGMSTypeNormal;
            break;
    }
}

-(UIView*) mapView: (GMSMapView*)mapView markerInfoWindow:(GMSMarker *)marker
{
    MyCustomMarker * infoWindow = [[[NSBundle mainBundle]loadNibNamed:@"MyCustomMarker" owner:self options:nil]objectAtIndex:0];
    
    infoWindow.title.text = marker.title;
    infoWindow.detail.text = marker.snippet;
    infoWindow.image.image = [UIImage imageNamed:@"australia"];
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    MyWebViewViewController * myWebView = [[MyWebViewViewController alloc]init];
    
    [self presentViewController:myWebView animated:YES completion:nil];
    
   
}

@end
