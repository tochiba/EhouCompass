//
//  NADNativeViewRendering.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import "NADNativeImageView.h"
#import "NADNativeLabel.h"

@protocol NADNativeViewRendering <NSObject>

@required

/**
 * Return the NADNativeLabel for the PR text.
 *
 * @return a NADNativeLabel that is used for the PR text.
 */
- (NADNativeLabel *)prTextLabel;

@optional

/**
 * Return the NADNativeImageView for the AD image.
 *
 * @return a NADNativeImageView that is used for the AD image.
 */
- (NADNativeImageView *)adImageView;

/**
 * Return the NADNativeImageView for the logo image.
 *
 * @return a NADNativeImageView that is used for the logo image.
 */
- (NADNativeImageView *)logoImageView;

/**
 * Return the NADNativeLabel for the short text.
 *
 * @return a NADNativeLabel that is used for the short text.
 */
- (NADNativeLabel *)shortTextLabel;

/**
 * Return the NADNativeLabel for the long text.
 *
 * @return a NADNativeLabel that is used for the long text.
 */
- (NADNativeLabel *)longTextLabel;

/**
 * Return the NADNativeLabel for the promotion url.
 *
 * @return a NADNativeLabel that is used for the promotion url.
 */
- (NADNativeLabel *)promotionUrlLabel;

/**
 * Return the NADNativeLabel for the promotion name.
 *
 * @return a NADNativeLabel that is used for the promotion name.
 */
- (NADNativeLabel *)promotionNameLabel;

/**
 * Return the NADNativeLabel for the action button text.
 *
 * @return a NADNativeLabel that is used for the action button text.
 */
- (NADNativeLabel *)actionButtonTextLabel;

@end
