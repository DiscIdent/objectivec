/*
 * Copyright (c) 2008, DiscIdent
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the "DiscIdent" nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY DiscIdent ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL DiscIdent BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import <Cocoa/Cocoa.h>

@interface DiscIdentQuery : NSObject {
    NSMutableData* receivedData;
    NSURLRequest* request;
    NSURLConnection* connection;
    /**/
    NSString* fingerprint;
    id delegate;
    void* userInfo;
}

@property (readonly) NSString* fingerprint;
@property (assign) id delegate;
@property (assign) void* userInfo;

+ (id) queryWithFingerprint:(NSString*)fingerprint;
+ (id) queryWithFingerprint:(NSString*)fingerprint delegate:(id)delegate userInfo:(void*)userInfo startImmediately:(BOOL)startImmediately;
+ (id) queryWithFingerprint:(NSString*)fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval;
+ (id) queryWithFingerprint:(NSString*)fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval delegate:(id)delegate userInfo:(void*)userInfo startImmediately:(BOOL)startImmediately;

- (id) initWithFingerprint:(NSString*)fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval;

- (void) start;
- (void) cancel;

@end

@interface NSObject (DiscIdentQueryDelegate)

- (void) discIdentQuery:(DiscIdentQuery*)query didReceiveResponse:(NSDictionary*)response userInfo:(void*)userInfo;
- (void) discIdentQuery:(DiscIdentQuery*)query didFailWithError:(NSError*)error userInfo:(void*)userInfo;

@end