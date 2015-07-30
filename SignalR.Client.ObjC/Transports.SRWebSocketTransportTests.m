//
//  SRWebSocketTransportTests.m
//  SignalR.Client.ObjC
//
//  Created by Joel Dart on 7/29/15.
//  Copyright (c) 2015 DyKnow LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SRWebSocket.h"
#import "SRWebSocketTransport.h"
#import "SRWebSocketConnectionInfo.h"
#import "SRHeartbeatMonitor.h"
#import "SRConnectionState.h"
#import "SRConnection.h"

@interface SRWebSocketTransportTests : XCTestCase

@end

@interface SRWebSocketTransport () <SRWebSocketDelegate>

@property (strong, nonatomic, readonly) SRWebSocket *webSocket;
@property (strong, nonatomic, readonly) SRWebSocketConnectionInfo *connectionInfo;
- (void)performConnect:(void (^)(id response, NSError *error))block reconnecting:(BOOL)reconnecting;

@end

@implementation SRWebSocketTransportTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSetsReconnectDelay {
    
    id transport = [[SRWebSocketTransport alloc] init];
    XCTAssertEqual(@2, [transport reconnectDelay]);
}

- (void)testFailDoesNotCallReconnectIfAborting {
    id transport = [[SRWebSocketTransport alloc] init];
    id transportMock = [OCMockObject partialMockForObject:transport];
    id connectionInfoMock = [SRWebSocketConnectionInfo alloc];
    id connection = [SRConnection alloc];
    id socket = [OCMockObject mockForClass: [SRWebSocket class]];
    [[[transportMock stub] andReturnValue: connectionInfoMock] connectionInfo];
    connectionInfoMock = [connectionInfoMock initConnection:connection data: @"TEst-DAta??"];//chains
    [connection setValue:[NSNumber numberWithInt:connected] forKey:@"state"];
    //    [[[connectionMock stub] andReturn:@YES] changeState:connected toState:reconnecting];
       //assert.doesnotcall
    [[transportMock reject] performConnect:nil reconnecting:YES];
    
    [transport abort:nil timeout:@9 connectionData:@"more-data??"];
    [transport webSocket:socket didFailWithError:nil];
    
    [[transportMock expect] performConnect:nil reconnecting:YES];
}

- (void)testFailCallsReconnectIfNotAborting {
    id transport = [[SRWebSocketTransport alloc] init];
    id transportMock = [OCMockObject partialMockForObject:transport];
    id connectionInfoMock = [SRWebSocketConnectionInfo alloc];
    id connectionMock = [OCMockObject niceMockForProtocol:@protocol(SRConnectionInterface)];
    id socket = [OCMockObject mockForClass: [SRWebSocket class]];
    [[[transportMock stub] andReturnValue: connectionInfoMock] connectionInfo];
    connectionInfoMock = [connectionInfoMock initConnection:connectionMock data: @"TEst-DAta??"];//chains
    [[[connectionMock stub] andReturn:@YES] changeState:connected toState:reconnecting];
    
    [transport webSocket:socket didFailWithError:nil];
    
    [[transportMock expect] performConnect:nil reconnecting:YES];
    [transportMock verify];
}

@end
