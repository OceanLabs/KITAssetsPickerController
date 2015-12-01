//
//  KITAsset.h
//  KITAssetsPickerDemo
//
//  Created by Konstadinos Karayannis on 20/10/15.
//  Copyright © 2015 Clement T. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol KITAssetDataSource <NSObject, NSCoding>
/**
 *  The mime type of the image. @"image/png" or @"image/jpeg"
 *
 *  @return The mime type of the image
 */
- (NSString *)mimeType;

/**
 *  Provide the length of the data
 *
 *  @param handler Handler to provide the length of the data asynchronously
 */
- (void)dataLengthWithCompletionHandler:(void(^)(long long dataLength, NSError *error))handler;

/**
 *  The data of the image
 *
 *  @param handler Handler to provide the data of the image asynchronously
 */
- (void)dataWithCompletionHandler:(void(^)(NSData *data, NSError *error))handler;

- (void)thumbnailImageWithCompletionHandler:(void(^)(UIImage *image))handler;

- (CGFloat)pixelWidth;
- (CGFloat)pixelHeight;

@optional
/**
 *  Optional method to cancel loading of the image (for example downloading from the network)
 */
- (void)cancelAnyLoadingOfData;

@end
