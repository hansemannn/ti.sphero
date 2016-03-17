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

-(TiSpheroRobotProxy*)robotProxy
{
    if (robotProxy == nil) {
        robotProxy = [[TiSpheroRobotProxy alloc] _initWithPageContext:[self pageContext]];
    }
    
    return robotProxy;
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

#pragma mark Delegates

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    switch(n.type) {
        case RKRobotConnecting:
            NSLog(@"[DEBUG] Connecting to robot ...");
            break;
        case RKRobotOnline: {
            RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }
            if ([[self robotProxy] robot] != nil) {
                NSLog(@"[ERROR] You are already connected to a robot (%@). Call `disconnect()` and search again", [[[self robotProxy] robot] name]);
                return;
            }
            NSLog(@"[DEBUG] Connected to robot (%@)", [[[self robotProxy] robot] name]);
            [[self robotProxy] setRobot:convenience];
            break;
        }
        case RKRobotDisconnected:
            NSLog(@"[DEBUG] Disconnected from robot");
            [[self robotProxy] setRobot:nil];
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
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{@"status": NUMINT(type)}];
    
    if (type == RKRobotOnline) {
        [event setObject:robotProxy forKey:@"robot"];
    }
    
    [self fireEvent:@"connectionchange" withObject:event];
}

@end
