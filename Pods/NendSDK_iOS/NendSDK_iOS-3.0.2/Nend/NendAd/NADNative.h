//
//  NADNative.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADNativeViewRendering.h"

typedef NS_ENUM(NSInteger, NADNativeAdvertisingExplicitly) {
    NADNativeAdvertisingExplicitlyPR,
    NADNativeAdvertisingExplicitlySponsored,
    NADNativeAdvertisingExplicitlyAD,
    NADNativeAdvertisingExplicitlyPromotion,
};

@interface NADNative : NSObject

- (void)intoView:(UIView<NADNativeViewRendering> *)view;

@end