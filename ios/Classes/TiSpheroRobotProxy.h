/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiUtils.h"
#import <RobotKit/RobotKit.h>

@interface TiSpheroRobotProxy : TiProxy {
    
}

@property(nonatomic,retain) RKConvenienceRobot *robot;

- (void)setLEDColor:(id)value;

- (void)startDrivingWithHeadingAndVelocity:(id)args;

- (void)stopDriving:(id)unused;

@end
