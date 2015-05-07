//
//  Sniffer.h
//  Sniffer
//
//  Created by apple on 15/3/23.
//  Copyright (c) 2015年 longsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventListener <NSObject>
- (void)onDeviceOnline:(NSString*)ip;
@end

@interface Sniffer : NSObject

@property (strong, nonatomic) id<EventListener> delegate;

- (NSString*)getVersion;

- (NSError*)startSniffer:(NSString*)ssid password:(NSString*)password;

- (void)stopSniffer;

@end
