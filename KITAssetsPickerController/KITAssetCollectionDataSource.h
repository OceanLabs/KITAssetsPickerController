//
//  KITAssetCollection.h
//  KITAssetsPickerDemo
//
//  Created by Konstadinos Karayannis on 20/10/15.
//  Copyright © 2015 Clement T. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KITAssetCollectionDataSource <NSObject, NSCopying, NSFastEnumeration>

- (NSString *)title;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)obj;

@end
