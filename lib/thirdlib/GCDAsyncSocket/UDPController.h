//
//  UDPController.h
//  Wukoon1220
//
//  Created by netcom-apple on 15/1/7.
//  Copyright (c) 2015年 chenjg. All rights reserved.
//

#ifndef Wukoon1220_UDPController_h
#define Wukoon1220_UDPController_h

#import <Foundation/Foundation.h>

@protocol UDPControllerDelegate <NSObject>
@optional

- (void) udpGetWukoonIp:(NSString*)ip mode:(NSString*)mode;

- (void) udpReceiveDataString:(NSString *)string;

@end


@interface UDPController : NSObject

@property(strong,nonatomic) id<UDPControllerDelegate> delegate;

- (id) initWithDelegate:(id)delegate;

- (NSError*) startUDP;

- (void) stopUdp;

- (void) findWukoonWithBroadcast;


- (void) findWukoonWithIp:(NSString *)ip;

- (void) sendDataWithIP:(NSString*)ip dataString:(NSString*)string;


@end

#endif
