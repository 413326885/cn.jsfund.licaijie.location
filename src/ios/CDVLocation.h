//
// Created by NikSun on 15/3/12.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <QMapKit/QMapKit.h>

@interface CDVLocation : CDVPlugin<QMapViewDelegate>
@property (nonatomic, strong) QMapView *mapView;
@property (nonatomic, strong) NSString *myCallbackId;
@property (nonatomic, copy) NSString *key;
- (void)init:(CDVInvokedUrlCommand *)command;
@end

