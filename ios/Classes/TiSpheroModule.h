/**
 * ti.sphero
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <RobotKit/RobotKit.h>

@interface TiSpheroModule : TiModule
{
    RKConvenienceRobot *robot;
}

- (void)startDiscovery:(id)unused;

- (void)stopDiscovery:(id)unused;

- (void)disconnectAll:(id)unused;

- (NSArray*)connectingRobots;

- (NSArray*)connectedRobots;

- (NSArray*)onlineRobots;

- (NSNumber*)isDiscovering:(id)unused;

- (void)setLEDColor:(id)value;

- (void)startDrivingWithHeadingAndVelocity:(id)args;

- (void)stopDriving:(id)unused;


@end
