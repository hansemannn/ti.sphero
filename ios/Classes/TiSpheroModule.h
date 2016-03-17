/**
 * ti.sphero
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "TiSpheroRobotProxy.h"
#import <RobotKit/RobotKit.h>

@interface TiSpheroModule : TiModule
{
    TiSpheroRobotProxy *robotProxy;
}

- (void)startDiscovery:(id)unused;

- (void)stopDiscovery:(id)unused;

- (void)disconnectAll:(id)unused;

- (NSArray*)connectingRobots;

- (NSArray*)connectedRobots;

- (NSArray*)onlineRobots;

- (NSNumber*)isDiscovering:(id)unused;

@end
