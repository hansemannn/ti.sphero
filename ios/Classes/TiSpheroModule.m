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

-(id)moduleGUID
{
	return @"c4830ffe-e6a9-4a7c-aa59-700b91c64088";
}

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
    [[RKRobotDiscoveryAgent sharedAgent] removeNotificationObserver:self];
    
    [super dealloc];
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

- (NSNumber*)isDiscovering:(id)unused
{
    return NUMBOOL([[RKRobotDiscoveryAgent sharedAgent] isDiscovering]);
}

#pragma mark Delegates

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    NSLog(@"[INFO] Received state notification: %i", n.type);
    
    switch(n.type) {
        case RKRobotConnecting:
            NSLog(@"[INFO] Connecting to robot (%@) ...", [n.robot name]);
            break;
        case RKRobotOnline: {
            NSLog(@"[INFO] Connected to robot (%@)", [n.robot name]);
            break;
        }
        case RKRobotDisconnected:
            NSLog(@"[INFO] Disconnected from robot (%@)", [n.robot name]);
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
    NSMutableDictionary *event = [@{@"status": NUMINT(notification.type)} mutableCopy];
    
    if (notification.type == RKRobotOnline) {
        TiSpheroRobotProxy *proxy = [[TiSpheroRobotProxy alloc] _initWithPageContext:[self pageContext]
                                                                            andRobot:[RKConvenienceRobot convenienceWithRobot:notification.robot]];
        [event setObject:proxy forKey:@"robot"];
    }
    
    [self fireEvent:@"connectionchange" withObject:event];
}

@end
