//
//  NADNativeClient.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NADNative.h"
#import "NADNativeError.h"
#import "NADNativeLogger.h"

typedef void (^NADNativeCompletionBlock)(NADNative *ad, NSError *error);

@protocol NADNativeDelegate <NSObject>

@optional
- (void)nadNativeDidClickAd:(NADNative *)ad;
- (void)nadNativeDidDisplayAd:(NADNative *)ad success:(BOOL)success;

@end

@interface NADNativeClient : NSObject

@property (nonatomic, assign) id<NADNativeDelegate> delegate;

/**
 * Initializes a client object.
 *
 * @param spotId
 * @param apiKey
 * @param advertisingExplicitly
 *
 * @return A NADNativeClient object.
 */
- (instancetype)initWithSpotId:(NSString *)spotId apiKey:(NSString *)apiKey advertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly;

/**
 * Load native ad.
 *
 * @param completionBlock
 */
- (void)loadWithCompletionBlock:(NADNativeCompletionBlock)completionBlock;

@end