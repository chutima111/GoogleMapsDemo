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
{
    double latitude, longitude;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSPlacesClient *placeClient;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchBar setDelegate:self];
    [self.locationManager setDelegate:self];

    
    _placeClient = [[GMSPlacesClient alloc]init];
    
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    latitude = self.locationManager.location.coordinate.latitude;
    longitude = self.locationManager.location.coordinate.longitude;
    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.741316
//                                                            longitude:-73.989980
//                                                                 zoom:13.5];
    
    GMSCameraPosition *currentCamera = [GMSCameraPosition cameraWithLatitude:latitude
                                                                   longitude:longitude
                                                                        zoom:13.5];

    
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.camera = currentCamera;
    self.mapView_.delegate = self;
        

    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(40.741426, -73.990136);
    marker.title = @"Turn To Tech";
    marker.snippet = @"Boot Camp";
    marker.userData = @"http://turntotech.io/";
    marker.map = self.mapView_;
    marker.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker1 = [[GMSMarker alloc]init];
    marker1.position = CLLocationCoordinate2DMake(40.741362, -73.988290);
    marker1.title = @"Shake Shack";
    marker1.snippet = @"Restaurant";
    marker1.userData = @"https://www.shakeshack.com/";
    marker1.map = self.mapView_;
    marker1.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker2 = [[GMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake(40.740523, -73.990855);
    marker2.title = @"KatAndTheo";
    marker2.snippet = @"Restuarant";
    marker2.userData = @"http://katandtheo.com/";
    marker2.map = self.mapView_;
    marker2.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker3 = [[GMSMarker alloc]init];
    marker3.position = CLLocationCoordinate2DMake(40.741495, -73.990348);
    marker3.title = @"Starbucks";
    marker3.snippet = @"Restuarant";
    marker3.userData = @"http://www.starbucks.com/";
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
    infoWindow.image.image = [UIImage imageNamed:marker.title];;
    if (infoWindow.image.image == nil) {
        infoWindow.image.image = [self getImageFromDocumentDirectory:marker.title];
    }
    infoWindow.urlString = marker.userData;
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    MyWebViewViewController * myWebView = [[MyWebViewViewController alloc]init];
    myWebView.urlString = marker.userData;
    myWebView.title = marker.title;
    
    [self presentViewController:myWebView animated:YES completion:nil];
    
   
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchBar resignFirstResponder];
    
    // Remove all the markers
    [self.mapView_ clear];
    
    // Start to search here
    [self searchLocations];
    
}


-(void)searchLocations
{
    NSString *searchText = self.searchBar.text;
  
    
    //SAMPLE URL
    //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&type=restaurant&name=cruise&key=AIzaSyDKX0p74aoKzjOplh_bx_lXhOyV0lPj_Zk
    
    
    NSString *webServiceUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&type=establishment&name=%@&key=AIzaSyDKX0p74aoKzjOplh_bx_lXhOyV0lPj_Zk", latitude, longitude, searchText];
    
    NSURL *googleURL = [NSURL URLWithString:webServiceUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:googleURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
    {
        NSLog(@"Download done");
        
        NSDictionary *resultsDict = [self convertJsonDataToDictionary:data];
        
        if (resultsDict == nil) {
            // Show the Alert View
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No result" message:@"Try searching for anohter name" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            
            [alert addAction:defaultAction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });

            
        }
        else {

            // Get the result locations put in array
            NSArray *resultsArray = [resultsDict objectForKey:@"results"];
          
            // Loop through each element or location in the array
            for (NSDictionary *locationsDict in resultsArray) {
                
                // Get the location coordinate
                NSDictionary *geometryDict = [locationsDict objectForKey:@"geometry"];
                NSDictionary *coordinatesDict = [geometryDict objectForKey:@"location"];
                NSNumber *locationLat = [coordinatesDict objectForKey:@"lat"];
                NSNumber *locationLong = [coordinatesDict objectForKey:@"lng"];
               
                
                // Get the location name
                NSString *locationName = [locationsDict objectForKey:@"name"];
                
                // Get the location ID
                NSString *locationID = [locationsDict objectForKey:@"place_id"];
                [self placeIdSearch:locationID withCompletionHandler:^(NSString *websiteString) {
                    // Get the photo reference
                    NSArray *photoArray = [locationsDict objectForKey:@"photos"];
                    NSDictionary *photoDict = [photoArray objectAtIndex:0];
                    NSString *photoRefString = [photoDict objectForKey:@"photo_reference"];
                    
                    [self getAndSavePhoto:photoRefString photoName:locationName withCompletionHandler:^(UIImage *resultImage) {
                        // Get the location type
                        NSArray *locationTypeArray = [locationsDict objectForKey:@"types"];
                        NSString *locaitonType = locationTypeArray[0];
                        
                        // Add marker for search location
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self makeMarker:locationName setLatitude:[locationLat doubleValue] setLongitude:[locationLong doubleValue] locationType:locaitonType locationPhoto:resultImage locationWebSite:websiteString];
                        });
                    }];
                }];
            }
        }
            
    }]resume];
    
    
    
}

#pragma mark - Convenient Method

// Make marker method
-(GMSMarker *)makeMarker:(NSString *)locationName setLatitude:(double)locationLat setLongitude:(double)locationLong locationType:(NSString *)type locationPhoto:(UIImage *)photo locationWebSite:(NSString *)webSite {
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(locationLat, locationLong);
    marker.title = locationName;
    marker.snippet = type;
    marker.userData = webSite;
    marker.map = self.mapView_;
    marker.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    return marker;
}

// Download photo reference from url and get the image,maybe?
-(void)getAndSavePhoto:(NSString *)photoRefString photoName:(NSString *)photoRefName withCompletionHandler:(void (^)(UIImage *resultImage))completionHandler
{
    NSString *photoString = photoRefString;
    NSString *googleApi = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&maxheight=100&photoreference=";
    NSString *googleApiKey = @"&key=AIzaSyDKX0p74aoKzjOplh_bx_lXhOyV0lPj_Zk";
    NSString *photoUrlString = [NSString stringWithFormat:@"%@%@%@", googleApi, photoString, googleApiKey];
    
    NSURL *url = [NSURL URLWithString:photoUrlString];
    NSURLSessionDownloadTask *downloadImageTask = [[NSURLSession sharedSession] downloadTaskWithURL:url
                                                                                  completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        UIImage *downloadImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        
        if(downloadImage != nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:photoRefName];
            NSData *data = UIImagePNGRepresentation(downloadImage);
            [data writeToFile:path atomically:YES];
            
            completionHandler([self getImageFromDocumentDirectory:photoRefName]);
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    [downloadImageTask resume];
}

// Save photo reference from google places API to document directory
// set the name of the photo ref is the same name with location name
-(void)savePhotoReference:(NSString *)photoRefString photoName:(NSString *)photoRefName
{
    NSString *photoString = photoRefString;
    NSString *googleApi = @"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=";
    NSString *googleApiKey = @"&key=AIzaSyDKX0p74aoKzjOplh_bx_lXhOyV0lPj_Zk";
    NSString *photoUrlString = [NSString stringWithFormat:@"%@%@%@", googleApi, photoString, googleApiKey];
    
    NSURL *url = [NSURL URLWithString:photoUrlString];
    NSURLSessionDownloadTask *downloadImageTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        UIImage *downloadImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        
        // Move the file from temp directory to document directory
        if (downloadImage != nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:photoRefName];
            NSData *data = UIImagePNGRepresentation(downloadImage);
            [data writeToFile:path atomically:YES];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [downloadImageTask resume];

}


// Save image from url to document directory
-(void)saveImageUrl:(NSString *)imageUrlString imageName:(NSString *)imageName {
    
    NSURL *url = [NSURL URLWithString:imageUrlString];
    NSURLSessionDownloadTask *downloadImageTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        UIImage *downloadImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        
        // Move the file from temp directory to document directory
        if (downloadImage != nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:imageName];
            NSData *data = UIImagePNGRepresentation(downloadImage);
            [data writeToFile:path atomically:YES];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [downloadImageTask resume];
}

// Get the image from document directory
-(UIImage *)getImageFromDocumentDirectory:(NSString *)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:imageName]; // imageName is location name
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    return image;
}

// Convert Json data to dictionary
-(NSDictionary *)convertJsonDataToDictionary:(NSData *)jsonData {
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (! jsonDict) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return jsonDict;
        
    }
}

-(void)placeIdSearch:(NSString *)placeID withCompletionHandler:(void (^)(NSString *websiteString))completionHandler
{
    NSString *firstUrlString = @"https://maps.googleapis.com/maps/api/place/details/json?placeid=";
    NSString *googleApiKey = @"&key=AIzaSyDKX0p74aoKzjOplh_bx_lXhOyV0lPj_Zk";
    NSString *completeUrlString = [NSString stringWithFormat:@"%@%@%@", firstUrlString, placeID, googleApiKey];
    
    NSURL *url = [NSURL URLWithString:completeUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          NSLog(@"Download place id is done");
          
          NSDictionary *dataDict = [self convertJsonDataToDictionary:data];
          NSDictionary *resultsDict = [dataDict objectForKey:@"result"];
          
          if (resultsDict != nil) {
          NSString *website = [resultsDict objectForKey:@"website"];
              
              completionHandler(website);
        
          }
          else {
              NSLog(@"Error: %@", error.localizedDescription);
          }
      }] resume];

    
}
                                     
                                     

//-(void)searchForLocationsByAutoComplete{
//    
//    // Use GMSAutocompleteFilter to find the location
//    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc]init];
//    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
//    
//    // Set the size of the bounds for search, set the bound
//    GMSVisibleRegion visibleRegion = self.mapView_.projection.visibleRegion;
//    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
//                                                                       coordinate:visibleRegion.nearRight];
//    
//    // When the search is done, it will excute the call back
//    // All the locations will be in results Array as a GMSAutocompletePrediction which is give the whole string of location information
//    
//    [_placeClient autocompleteQuery:self.searchBar.text
//                             bounds:bounds
//                             filter:filter
//                           callback:^(NSArray *results, NSError *error) {
//                               if (error != nil) {
//                                   NSLog(@"Autocomplete error %@", error.localizedDescription);
//                                   return ;
//                               } else {
//                    
//                                   for (GMSAutocompletePrediction *result in results) {
//                                       
//    // I need to convert GMSAutocompletePrediction result into GMSPlace to get the location info to make a marker
//                                       [_placeClient lookUpPlaceID:result.placeID
//                                                                            callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
//                                           NSLog(@"name = %@, lat = %f, long = %f, website = %@, type = %@", result.name, result.coordinate.latitude, result.coordinate.longitude, result.website, result.types[0]);
//                                                                                
//    // Add new markers here
//    GMSMarker *marker = [[GMSMarker alloc]init];
//    marker.position = CLLocationCoordinate2DMake(result.coordinate.latitude, result.coordinate.longitude);
//    marker.title = result.name;
//    marker.snippet = result.types[0];
//    marker.userData = [result.website absoluteString];
//    marker.map = self.mapView_;
//    marker.infoWindowAnchor = CGPointMake(0.5, -0.25);
//                                                                                
//                                       }];
//                                       
//                                   }
//                               }
//    }];
//   
//    
//}


@end
