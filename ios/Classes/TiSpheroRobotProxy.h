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

- (id)_initWithPageContext:(id<TiEvaluator>)context andRobot:(RKConvenienceRobot*)robot;

- (void)startDrivingWithHeadingAndVelocity:(id)args;

- (void)stopDriving:(id)unused;

- (void)setLEDColor:(id)value;

- (void)setBackLEDBrightness:(id)value;

- (void)resetHeading:(id)unused;

- (void)disconnect:(id)unused;

- (void)runMacro:(id)args;

@end