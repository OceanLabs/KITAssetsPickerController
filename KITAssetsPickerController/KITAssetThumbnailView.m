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
#import "KITAssetsPickerDefines.h"
#import "KITAssetThumbnailView.h"
#import "KITAssetThumbnailOverlay.h"
#import "NSDateFormatter+KITAssetsPickerController.h"



@interface KITAssetThumbnailView ()

@property (nonatomic, strong) KITAssetThumbnailOverlay *overlay;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end



@implementation KITAssetThumbnailView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _showsDuration              = YES;
        self.opaque                 = YES;
        self.clipsToBounds          = YES;
        self.isAccessibilityElement = NO;
        
        [self setupViews];
    }
    
    return self;
}

#pragma markt - Setup

- (void)setupViews
{
    self.backgroundColor = KITAssetsPikcerThumbnailBackgroundColor;
    
    UIImageView *backgroundView = [UIImageView new];
    backgroundView.contentMode = UIViewContentModeCenter;
    backgroundView.tintColor = KITAssetsPikcerThumbnailTintColor;
    self.backgroundView = backgroundView;
    
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView = imageView;
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.imageView];
}


#pragma markt - Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundView.image = backgroundImage;
}


#pragma markt - Override set bounds

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self.overlay setFrame:bounds];
    [self.overlay setNeedsDisplay];
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self.backgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

#pragma - Bind asset and image

- (void)bind:(UIImage *)image asset:(id<KITAssetDataSource> )asset;
{
    [self setupOverlayForAsset:asset];
    
    self.imageView.image = image;
    self.backgroundView.hidden = (image != nil);
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setupOverlayForAsset:(id<KITAssetDataSource> )asset
{
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}


#pragma - Bind asset collection and image

- (void)bind:(UIImage *)image assetCollection:(id<KITAssetCollectionDataSource>)assetCollection;
{
    [self setupOverlayForAssetCollection:assetCollection];
    
    self.imageView.image = image;
    self.backgroundView.hidden = (image != nil);
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setupOverlayForAssetCollection:(id<KITAssetCollectionDataSource>)assetCollection
{
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}



@end
