//
//  UDPController.m
//  Wukoon1220
//
//  Created by netcom-apple on 15/1/7.
//  Copyright (c) 2015年 chenjg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "UDPController.h"
#import "StringDefine.h"

@interface UDPController()<GCDAsyncUdpSocketDelegate>
{

}
@end

@implementation UDPController
{
    GCDAsyncUdpSocket *udpSocket;
    BOOL udpIsRunning;
    NSString* WKIP;
}

-(id) init
{
    self = [super init];
    if (self){
        udpIsRunning = NO;
        udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (id) initWithDelegate:(id)delegate
{
    self = [self init];
    if (self){
        self.delegate = delegate;
    }
    return  self;
}

- (NSError*) startUDP
{
    NSError* error;
    [self stopUdp];
    if (![udpSocket bindToPort:UDP_PORT error:&error]){
        NSLog(@"bindToPorterror:%@",error);
        return error;
    }
    if (![udpSocket enableBroadcast:true error:&error]){
        NSLog(@"enableBroadcasterror:%@",error);
        [udpSocket close];
        return  error;
    }
    udpIsRunning = YES;
    return nil;
}

- (void) stopUdp
{
    if (udpIsRunning){
        [udpSocket close];
        udpIsRunning = NO;
    }
}

- (void) sendDataWithIP:(NSString*)ip dataString:(NSString*)string
{
    NSLog(@"sendDataWithIP:%@,data:%@",ip,string);
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:ip port:UDP_PORT withTimeout:UDPREAD_TIMEOUT tag:0];
}

- (void) findWukoonWithBroadcast
{
    [self sendDataWithIP:BROADCAST_HOST dataString:[self findCommand]];
}

- (void) findWukoonWithIp:(NSString *)ip
{
    [self sendDataWithIP:ip dataString:[self findCommand]];
}

-(NSString *) findCommand{
    NSMutableDictionary *commandDict = [[NSMutableDictionary alloc]init];
    [commandDict setObject:@"DeviceFind" forKey:@"cmd"];
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    [commandDict setObject:locationString forKey:@"at"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commandDict options:NSJSONWritingPrettyPrinted error:nil];
    if ([jsonData length] > 0) {
        NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *commandString = [NSString stringWithFormat:@"Content-Length:%lu;%@",(unsigned long)jsonString.length,jsonString];
        return commandString;
    }
    return  nil;
}
/************************************************************************/
/*                       GCDAsyncUdpSocketDelegate                      */
/************************************************************************/

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(id)tag{
    NSLog(@"udpSocketDidSendData");
    [udpSocket beginReceiving:nil];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString* dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"udpSocketdidReceiveData:%@",dataString);
    if ([dataString rangeOfString:@"res_cmd"].location != NSNotFound){
        NSRange range = [dataString rangeOfString:@";"];
        NSString *jsonString = [dataString substringFromIndex:range.location + 1];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        if (jsonDict) {
            NSLog(@"jsonDict%@",jsonDict);
            if (self.delegate) {
                NSDictionary *infoDict = [jsonDict objectForKey:@"device_info"];
                if (infoDict) {
                    NSString *uuid = [infoDict objectForKey:@"uuid"];
                    if (uuid) {
                        [self.delegate udpReceiveDataString:uuid];
                    }
                }
            }
        }
    }
}


@end

