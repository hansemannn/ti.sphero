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
    [super startup];
    
    [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
	NSLog(@"[INFO] %@ loaded",self);
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
    RELEASE_TO_NIL(robotProxies);
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

-(NSMutableDictionary<NSString*, TiSpheroRobotProxy*>*)robotProxies
{
    if (robotProxies == nil) {
        robotProxies = [NSMutableDictionary dictionary];
    }
    
    return robotProxies;
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

- (id)connectedRobots
{
    return [self robotProxies];
}

- (NSNumber*)isDiscovering:(id)unused
{
    return NUMBOOL([[RKRobotDiscoveryAgent sharedAgent] isDiscovering]);
}

#pragma mark Delegates

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    switch(n.type) {
        case RKRobotConnecting:
            NSLog(@"[DEBUG] Connecting to robot (@) ...", [n.robot name]);
            break;
        case RKRobotOnline: {
            RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
            
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }

            NSLog(@"[DEBUG] Connected to robot (%@)", [convenience name]);

            if (![[self robotProxies] valueForKey:[convenience name]]) {
                TiSpheroRobotProxy *proxy = [[TiSpheroRobotProxy alloc] _initWithPageContext:[self pageContext] andRobot:convenience];
                [[self robotProxies] setObject:proxy forKey:[convenience name]];
            }
            
            break;
        }
        case RKRobotDisconnected:
            NSLog(@"[DEBUG] Disconnected from robot (@)", [n.robot name]);

            if (![[self robotProxies] valueForKey:[n.robot name]]) {
                [[self robotProxies] removeObjectForKey:[n.robot name]];
            }
            
            break;
        default:
            break;
    }
    
    [self fireConnectionEventWithNotification:n];
}

#pragma mark Constants

MAKE_SYSTEM_PROP(CONNECTION_STATUS_CONNECTING, RKRobotConnecting);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_CONNECTED, RKRobotConnected);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_DISCONNECTED, RKRobotDisconnected);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_ONLINE, RKRobotOnline);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_OFFLINE, RKRobotOffline);
MAKE_SYSTEM_PROP(CONNECTION_STATUS_FAILED_CONNECT, RKRobotFailedConnect);

#pragma mark Utils

- (void)fireConnectionEventWithNotification:(RKRobotChangedStateNotification*)notification
{
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{@"status": NUMINT(notification.type)}];
    
    if (notification.type == RKRobotOnline) {
        [event setObject:[[self robotProxies] valueForKey:[notification.robot name]] forKey:@"robot"];
    }
    
    [self fireEvent:@"connectionchange" withObject:event];
}

@end
