/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiSpheroRobotProxy.h"

@implementation TiSpheroRobotProxy

#pragma mark - Lifecycle

-(id)_initWithPageContext:(id<TiEvaluator>)context andRobot:(RKConvenienceRobot*)robot
{
    if (self = [super _initWithPageContext:context]) {
        [self setRobot:robot];
    }
    
    return self;
}

#pragma mark - Utility macros

#define VALIDATE_ROBOT \
if (![self isRobotConnected]) { \
NSLog(@"[ERROR] Ti.Sphero: No robot connected."); \
return; \
} \

#pragma mark - Public API's

#pragma mark Methods

- (void)startDrivingWithHeadingAndVelocity:(id)args
{
    VALIDATE_ROBOT
    
    id heading = [args objectAtIndex:0];
    id velocity = [args objectAtIndex:1];
    
    ENSURE_TYPE(heading, NSNumber);
    ENSURE_TYPE(velocity, NSNumber);
    
    [[self robot] driveWithHeading:[TiUtils intValue:heading def:0] andVelocity:[TiUtils floatValue:velocity def:0]];
}

- (void)stopDriving:(id)unused
{
    VALIDATE_ROBOT    
    [[self robot] stop];
}

- (void)setLEDColor:(id)value {
    VALIDATE_ROBOT
    
    TiColor *color = [TiUtils colorValue:value];
    CGColorRef nativeColor = [[color _color] CGColor];
    
    if (CGColorGetNumberOfComponents(nativeColor) == 4) {
        const CGFloat *components = CGColorGetComponents(nativeColor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        [[self robot] setLEDWithRed:red green:green blue:blue];
    }
}

- (void)setBackLEDBrightness:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    VALIDATE_ROBOT
    
    [[self robot] setBackLEDBrightness:[TiUtils floatValue:value]];
}

- (void)resetHeading:(id)unused
{
    VALIDATE_ROBOT
    [[self robot] setZeroHeading];
}

- (void)disconnect:(id)unused
{
    VALIDATE_ROBOT
    [[self robot] disconnect];
}

- (void)runMacro:(id)args
{
    id macro = [args objectAtIndex:0];
    id commandId = [args objectAtIndex:1];
    
    ENSURE_TYPE(macro, NSString);
    ENSURE_TYPE(commandId, NSNumber);
        
    [_robot macroSaveTemporary:[[[TiBlob alloc] initWithFile:[TiUtils stringValue:macro]] data]];
    [_robot sendCommand:[RKRunMacroCommand commandWithId:[TiUtils intValue:commandId]]];
}

#pragma mark Properties

- (NSString*)name
{
    VALIDATE_ROBOT
    return [[self robot] name];
}

- (NSString*)identifier
{
    VALIDATE_ROBOT
    return [[[self robot] robot] identifier];
}

- (NSString*)serialNumber
{
    VALIDATE_ROBOT
    return [[[self robot] robot] serialNumber];
}

- (NSNumber*)online
{
    VALIDATE_ROBOT
    return NUMBOOL([[self robot] isOnline]);
}

- (NSNumber*)connected
{
    return NUMBOOL([self isRobotConnected]);
}

- (NSNumber*)currentHeading
{
    VALIDATE_ROBOT
    return NUMFLOAT([[self robot] currentHeading]);
}

#pragma mark - Utilities

- (BOOL)isRobotConnected
{
    return ([self robot] && [[self robot] isConnected]);
}

@end
