/**
 * ti.sphero
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiSpheroModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiSpheroModule

#define VALIDATE_ROBOT \
if (![self isRobotConnected]) { \
    NSLog(@"[ERROR] Ti.Sphero: No robot connected."); \
    return; \
} \

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"c4830ffe-e6a9-4a7c-aa59-700b91c64088";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.sphero";
}

#pragma mark Lifecycle

-(void)startup
{
    [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
    
    [super startup];
    
	NSLog(@"[INFO] %@ loaded",self);
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

- (void)startDiscovery:(id)unused
{
    NSError *error;
    [[RKRobotDiscoveryAgent sharedAgent] startDiscoveryAndReturnError:&error];
}

- (void)stopDiscovery:(id)unused
{
    [[RKRobotDiscoveryAgent sharedAgent] stopDiscovery];
}

- (void)disconnectAll:(id)unused
{
    [[RKRobotDiscoveryAgent sharedAgent] disconnectAll];
}

- (NSArray*)connectingRobots
{
    return [[[RKRobotDiscoveryAgent sharedAgent] connectingRobots] array];
}

- (NSArray*)connectedRobots
{
    return [[[RKRobotDiscoveryAgent sharedAgent] connectedRobots] array];
}

- (NSArray*)onlineRobots
{
    return [[[RKRobotDiscoveryAgent sharedAgent] onlineRobots] array];
}

- (NSNumber*)isDiscovering:(id)unused
{
    return NUMBOOL([[RKRobotDiscoveryAgent sharedAgent] isDiscovering]);
}

- (void)startDrivingWithHeadingAndVelocity:(id)args
{
    VALIDATE_ROBOT
    
    id heading = [args objectAtIndex:0];
    id velocity = [args objectAtIndex:1];
    
    ENSURE_TYPE(heading, NSNumber);
    ENSURE_TYPE(velocity, NSNumber);
    
    [robot driveWithHeading:[TiUtils intValue:heading def:0] andVelocity:[TiUtils floatValue:velocity def:0]];
}

- (void)stopDriving:(id)unused
{
    VALIDATE_ROBOT
    
    [robot stop];
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

        [robot setLEDWithRed:red green:green blue:blue];
    }
}

- (NSString*)robotName:(id)unused
{
    VALIDATE_ROBOT
    
    return [robot name];
}

#pragma mark Delegates

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    switch(n.type) {
        case RKRobotConnecting:
            break;
        case RKRobotOnline: {
            RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }
            robot = convenience;
            break;
        }
        case RKRobotDisconnected:
            robot = nil;
            [RKRobotDiscoveryAgent startDiscovery];
            break;
        default:
            break;
    }
    
    [self fireConnectionEventWithType:n.type];
}

#pragma mark Constants

MAKE_SYSTEM_PROP(CONNECTION_STATUS_CONNECTING, RKRobotConnecting);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_CONNECTED, RKRobotConnected);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_DISCONNECTED, RKRobotDisconnected);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_ONLINE, RKRobotOnline);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_OFFLINE, RKRobotOffline);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_FAILED_CONNECT, RKRobotFailedConnect);

#pragma mark Utils

- (void)fireConnectionEventWithType:(RKRobotChangedStateNotificationType)type
{
    [self fireEvent:@"connectionchange" withObject:@{@"status": NUMINT(type)}];
}

- (BOOL)isRobotConnected
{
    return (robot && [robot isConnected]);
}

@end
