//
//  CTAssetCollectionDataSource.m
//  KITAssetsPickerDemo
//
//  Created by Konstadinos Karayannis on 04/11/15.
//  Copyright © 2015 Clement T. All rights reserved.
//

#import "AssetCollectionDataSource.h"
#import "AssetDataSource.h"

@interface AssetCollectionDataSource ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation AssetCollectionDataSource

- (instancetype)init{
    if (self = [super init]){
        _array = @[[[AssetDataSource alloc] init], [[AssetDataSource alloc] init]];
    }
    
    return self;
}

- (NSString *)title{
    return @"My 1337 Album";
}

- (id)copyWithZone:(NSZone *)zone{
    AssetCollectionDataSource *copy = [[AssetCollectionDataSource alloc] init];
    copy.array = [[NSArray alloc] initWithArray:self.array copyItems:NO];
    return copy;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    return [self.array countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSUInteger)count{
    return self.array.count;
}

- (id)objectAtIndex:(NSUInteger)index{
    return [self.array objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)obj{
    return [self.array indexOfObject:obj];
}



@end
