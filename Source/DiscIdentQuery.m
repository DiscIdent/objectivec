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
#import <DiscIdentKit/DiscIdentQuery.h>
#import <JSONKit/JSONKit.h>
#import <sys/syslimits.h>

NSString* const kDISC_IDENT_VERSION = @"v1";

#pragma mark -
@interface DiscIdentQuery (Private)
- (void) _fireDidFailWithError:(NSError*)error;
- (void) _fireDidReceiveResponse:(NSDictionary*)response;
@end

#pragma mark -
@implementation DiscIdentQuery
@synthesize fingerprint;
@synthesize delegate;
@synthesize userInfo;

+ (id) queryWithFingerprint:(NSString*)fingerprint
{
    return [[[DiscIdentQuery alloc] initWithFingerprint:fingerprint timeoutInterval:3.0] autorelease];
}

+ (id) queryWithFingerprint:(NSString*)fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval
{
    return [[[DiscIdentQuery alloc] initWithFingerprint:fingerprint timeoutInterval:timeoutInterval] autorelease];
}

+ (id) queryWithFingerprint:(NSString*)fingerprint delegate:(id)delegate userInfo:(void*)userInfo startImmediately:(BOOL)startImmediately
{
    return [DiscIdentQuery queryWithFingerprint:fingerprint timeoutInterval:3.0 delegate:delegate userInfo:userInfo startImmediately:startImmediately];
}

+ (id) queryWithFingerprint:(NSString*)fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval delegate:(id)delegate userInfo:(void*)userInfo startImmediately:(BOOL)startImmediately
{
    NSAssert(delegate, @"The delegate must not be nil.");
    DiscIdentQuery* query = [DiscIdentQuery queryWithFingerprint:fingerprint timeoutInterval:timeoutInterval];
    query.delegate = delegate;
    query.userInfo = userInfo;
    if (startImmediately) {
        [query start];
    }
    return query;
}

- (id) initWithFingerprint:(NSString*)_fingerprint timeoutInterval:(NSTimeInterval)timeoutInterval
{
    if (self = [super init]) {
        fingerprint = [_fingerprint retain];
        request = [[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://discident.com/%@/%@/", kDISC_IDENT_VERSION, _fingerprint]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeoutInterval] retain];
    }
    return self;
}

- (void) dealloc
{
    [fingerprint release];
    [connection release];
    [request release];
    [receivedData release];
    [super dealloc];
}

- (void) start
{
    NSAssert(!connection, @"This query has already been started.");
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:[self retain] startImmediately:YES];
}

- (void) cancel
{
    [connection cancel];
}

@end

#pragma mark -
@implementation DiscIdentQuery (NSURLConnectionDelegate)

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response 
{
    receivedData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data 
{
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)error 
{
    [receivedData release];
    receivedData = nil;
    [self _fireDidFailWithError:error];
    [self autorelease];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection 
{
    NSDictionary* response = nil;
    id exception = nil;
    if ([receivedData length] > 0) {
        @try {
            response = [NSDictionary dictionaryWithJSON:[[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease]];
        } @catch (id _exception) {
            exception = _exception;
        }
    }

    if (!response || exception) {
        [self _fireDidFailWithError:nil];
    } else {
        [self _fireDidReceiveResponse: response];
    }
    [self autorelease];
}

@end

#pragma mark -
@implementation DiscIdentQuery (Private)

- (void) _fireDidFailWithError:(NSError*)error
{
    if ([delegate respondsToSelector:@selector(discIdentQuery:didFailWithError:userInfo:)]) {
        @try {
            [delegate discIdentQuery:self didFailWithError:error userInfo:userInfo];
        } @catch (id _exception) {
            NSLog(@"DiscIdentQuery: Exception during discIdentQuery:didFailWithError: -- %@", _exception);
        }
    }
}

- (void) _fireDidReceiveResponse:(NSDictionary*)response  
{
    if ([delegate respondsToSelector:@selector(discIdentQuery:didReceiveResponse:userInfo:)]) {
        @try {
            [delegate discIdentQuery:self didReceiveResponse:response userInfo:userInfo];
        } @catch (id _exception) {
            NSLog(@"DiscIdentQuery: Exception during discIdentQuery:didReceiveResponse: -- %@", _exception);
        }
    }
}

@end
