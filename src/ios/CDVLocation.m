//
// Created by NikSun on 15/3/12.
//

#import "CDVLocation.h"


@implementation CDVLocation : CDVPlugin
- (void)init:(CDVInvokedUrlCommand *)command {
    self.myCallbackId = command.callbackId;
    self.key = [command argumentAtIndex:0];
    [QMapServices sharedServices].apiKey = self.key;
    self.mapView = [[QMapView alloc] initWithFrame: self.viewController.view.bounds];
    self.mapView.delegate = self;
    [_mapView setShowsUserLocation: YES];
    
}

- (void)mapView:(QMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [mapView setShowsUserLocation: NO];
    NSLog(@"%@", @"error for location");
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCallbackId];
}

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    //    [mapView setShowsUserLocation: NO];
    if (!updatingLocation) {
        return;
    }
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"%g",
                                 userLocation.location.coordinate.latitude];
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%g",
                                  userLocation.location.coordinate.longitude];
    
    NSString *url = [NSString
                     stringWithFormat: @"http://apis.map.qq.com/ws/geocoder/v1/?location=%@,%@&key=%@",
                     currentLatitude,
                     currentLongitude,
                     self.key
                     ];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                    timeoutInterval:10
                                    ];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError = nil;
    NSError *parseError = nil;
    NSURLResponse *urlResponse = nil;
    CDVPluginResult *pluginResult;
    
    
    NSData *regionResponse = [NSURLConnection
                              sendSynchronousRequest:request
                              returningResponse:&urlResponse
                              error:&requestError
                              ];
    
    if (requestError) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCallbackId];
        return;
    }
    NSString *aString = [[NSString alloc] initWithData:regionResponse encoding:NSUTF8StringEncoding];
    NSLog(@"regionResponse is %@", aString);
    
    NSDictionary* regionInfo = [NSJSONSerialization
                                JSONObjectWithData:regionResponse
                                options:NSJSONReadingAllowFragments
                                error:&parseError
                                ];
    
    if (parseError) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCallbackId];
        return;
    }
    
    if ([regionInfo[@"status"] isEqualToNumber:@0]) {
        
        NSString* location = [NSString stringWithFormat:
                              @"{longitude:%@,latitude:%@,cityCode:%@,cityName:%@}",
                              currentLongitude, currentLatitude,
                              regionInfo[@"result"][@"ad_info"][@"adcode"],
                              regionInfo[@"result"][@"ad_info"][@"city"]];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:location];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCallbackId];
}


@end





