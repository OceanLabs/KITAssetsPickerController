/*
 
 MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <PureLayout/PureLayout.h>
#import "KITAssetThumbnailOverlay.h"
#import "UIImage+KITAssetsPickerController.h"
#import "KITAssetCollectionDataSource.h"


@interface KITAssetThumbnailOverlay ()

@property (nonatomic, strong) UIImageView *gradient;
@property (nonatomic, strong) UIImageView *badge;
@property (nonatomic, strong) UILabel *duration;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end



@implementation KITAssetThumbnailOverlay

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = NO;
        self.clipsToBounds          = YES;
        self.isAccessibilityElement = NO;
        
        [self setupViews];
    }
    
    return self;
}


#pragma markt - Setup

- (void)setupViews
{
    UIImageView *gradient = [UIImageView newAutoLayoutView];
    gradient.image = [UIImage KITAssetsPickerImageNamed:@"GridGradient"];
    self.gradient = gradient;
    
    [self addSubview:self.gradient];
    
    UIImageView *badge = [UIImageView newAutoLayoutView];
    badge.tintColor = [UIColor whiteColor];
    self.badge = badge;
    
    [self addSubview:self.badge];
    
    UILabel *duration = [UILabel newAutoLayoutView];
    duration.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    duration.textColor = [UIColor whiteColor];
    duration.lineBreakMode = NSLineBreakByTruncatingTail;
//    duration.layoutMargins = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
    self.duration = duration;
    
    [self addSubview:self.duration];
}

#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self.gradient autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.gradient autoSetDimension:ALDimensionHeight toSize:self.gradient.image.size.height];
        [self.badge autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
        [self.badge autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        [self.duration autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
        [self.duration autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
        
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}


#pragma - Bind asset and duration

- (void)bind:(id<KITAssetDataSource> )asset duration:(NSString *)duration;
{
//    self.badge.layoutMargins = [self layoutMarginsForAsset:asset];
    self.duration.text = duration;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (UIEdgeInsets)layoutMarginsForAsset:(id<KITAssetDataSource> )asset
{
        return UIEdgeInsetsZero;
}


#pragma - Bind asset collection

- (void)bind:(id<KITAssetCollectionDataSource>)assetCollection;
{
//    self.badge.layoutMargins = [self layoutMarginsForAssetCollection:assetCollection];
    self.duration.text = nil;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];    
}

- (UIEdgeInsets)layoutMarginsForAssetCollection:(id<KITAssetCollectionDataSource>)assetCollection
{
    return UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
}

@end
