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
@import GooglePlaces;

@interface ViewController () <GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) GMSPlacesClient *placeClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _placeClient = [[GMSPlacesClient alloc]init];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.741316
                                                        longitude:-73.989980
                                                                 zoom:13.5];
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.camera = camera;
    self.mapView_.delegate = self;
    
    NSLog(@"my location: %@", _mapView_.myLocation);
    
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(40.741426, -73.990136);
    marker.title = @"Turn To Tech";
    marker.userData = @"http://turntotech.io/";
    marker.map = self.mapView_;
    marker.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker1 = [[GMSMarker alloc]init];
    marker1.position = CLLocationCoordinate2DMake(40.741362, -73.988290);
    marker1.title = @"Shake Shack";
    marker1.userData = @"https://www.shakeshack.com/";
    marker1.map = self.mapView_;
    marker1.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker2 = [[GMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake(40.740523, -73.990855);
    marker2.title = @"KatAndTheo";
    marker2.userData = @"http://katandtheo.com/";
    marker2.map = self.mapView_;
    marker2.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    [self.searchBar setDelegate:self];
    
   
    
/*    GMSMarker *marker = [[GMSMarker alloc] init];
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
 */

    
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
    infoWindow.image.image = [UIImage imageNamed:marker.title];
    infoWindow.urlString = marker.userData;
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    MyWebViewViewController * myWebView = [[MyWebViewViewController alloc]init];
    myWebView.urlString = marker.userData;
    
    [self presentViewController:myWebView animated:YES completion:nil];
    
   
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Start to search here
    [self placeAutoComplete];
}

-(void)placeAutoComplete {
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc]init];
    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    
    GMSVisibleRegion visibleRegion = self.mapView_.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                       coordinate:visibleRegion.nearRight];
    [_placeClient autocompleteQuery:self.searchBar.text
                             bounds:bounds
                             filter:filter
                           callback:^(NSArray *results, NSError *error) {
                               if (error != nil) {
                                   NSLog(@"Autocomplete error %@", error.localizedDescription);
                                   return ;
                               } else {
                                   for (GMSAutocompletePrediction *result in results) {
                                       [_placeClient lookUpPlaceID:result.placeID
                                                                            callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
                                           NSLog(@"name = %@, lat = %f, long = %f, website = %@", result.name, result.coordinate.latitude, result.coordinate.longitude, result.website);
                                       }];
                                       
                                   }
                               }
    }];
   
    
}


@end
