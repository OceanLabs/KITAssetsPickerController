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
#import "KITAssetsGridViewFooter.h"
#import "NSNumberFormatter+KITAssetsPickerController.h"
#import "NSBundle+KITAssetsPickerController.h"




@interface KITAssetsGridViewFooter ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end






@implementation KITAssetsGridViewFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupViews];
    }
    
    return self;
}


#pragma mark - Setup

- (void)setupViews
{
    UILabel *label = [UILabel newAutoLayoutView];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = KITAssetsGridViewFooterFont;
    label.textColor = KITAssetsGridViewFooterTextColor;
    
    self.label = label;
    [self addSubview:self.label];
}


#pragma mark - Appearance

- (UIFont *)font
{
    return self.label.font;
}

- (void)setFont:(UIFont *)font
{
    UIFont *labelFont = (font) ? font : KITAssetsGridViewFooterFont;
    self.label.font = labelFont;
}

- (UIColor *)textColor
{
    return self.label.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    UIColor *color = (textColor) ? textColor : KITAssetsGridViewFooterTextColor;
    self.label.textColor = color;
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self.label autoPinEdgesToSuperviewEdges];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)bind:(id<KITAssetCollectionDataSource> )result
{
 
    NSNumberFormatter *nf = [NSNumberFormatter new];
    NSString *numberOfPhotos = @"";
    
    NSUInteger photoCount = result.count;
    
    
    if (photoCount > 0)
                numberOfPhotos = [nf KITAssetsPickerStringFromAssetsCount:photoCount];
        
            if (photoCount > 0)
                self.label.text = [NSString stringWithFormat:KITAssetsPickerLocalizedString(@"%@ Photos", nil), numberOfPhotos];

            else
                self.label.text = @"";
    
    self.hidden = (result.count == 0);
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

@end