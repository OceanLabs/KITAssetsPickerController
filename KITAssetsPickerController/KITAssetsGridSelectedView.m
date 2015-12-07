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
#import "KITAssetsGridSelectedView.h"
#import "KITAssetCheckmark.h"




@interface KITAssetsGridSelectedView ()

@property (nonatomic, strong) KITAssetCheckmark *checkmark;
@property (nonatomic, strong) UILabel *selectionIndexLabel;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end





@implementation KITAssetsGridSelectedView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupViews];
        self.showsSelectionIndex = NO;
    }
    
    return self;
}


#pragma mark - Setup

- (void)setupViews
{
    self.backgroundColor = KITAssetsGridSelectedViewBackgroundColor;
    self.layer.borderColor = KITAssetsGridSelectedViewTintColor.CGColor;
    
    KITAssetCheckmark *checkmark = [KITAssetCheckmark newAutoLayoutView];
    self.checkmark = checkmark;
    [self addSubview:checkmark];
    
    UILabel *selectionIndexLabel = [UILabel newAutoLayoutView];
    selectionIndexLabel.textAlignment = NSTextAlignmentCenter;
    selectionIndexLabel.backgroundColor = self.tintColor;
    selectionIndexLabel.font = KITAssetsGridSelectedViewFont;
    selectionIndexLabel.textColor = KITAssetsGridSelectedViewTextColor;
    self.selectionIndexLabel = selectionIndexLabel;
    
    [self addSubview:self.selectionIndexLabel];
}


#pragma mark - Apperance

- (UIColor *)selectedBackgroundColor
{
    return self.backgroundColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)backgroundColor
{
    UIColor *color = (backgroundColor) ? backgroundColor : KITAssetsGridSelectedViewBackgroundColor;
    self.backgroundColor = color;
}

- (UIFont *)font
{
    return self.selectionIndexLabel.font;
}

- (void)setFont:(UIFont *)font
{
    UIFont *labelFont = (font) ? font : KITAssetsGridSelectedViewFont;
    self.selectionIndexLabel.font = labelFont;
}

- (UIColor *)textColor
{
    return self.selectionIndexLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    UIColor *color = (textColor) ? textColor : KITAssetsGridSelectedViewTextColor;
    self.selectionIndexLabel.textColor = color;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setTintColor:(UIColor *)tintColor
{
    UIColor *color = (tintColor) ? tintColor : KITAssetsGridSelectedViewTintColor;
    self.selectionIndexLabel.backgroundColor = color;
    self.layer.borderColor = color.CGColor;
}


#pragma mark - Accessors

- (void)setShowsSelectionIndex:(BOOL)showsSelectionIndex
{
    _showsSelectionIndex = showsSelectionIndex;
    
    if (showsSelectionIndex)
    {
        self.checkmark.hidden = YES;
        self.selectionIndexLabel.hidden = NO;
    }
    else
    {
        self.checkmark.hidden = NO;
        self.selectionIndexLabel.hidden = YES;
    }
}

- (void)setSelectionIndex:(NSUInteger)selectionIndex;
{
    _selectionIndex = selectionIndex;
    self.selectionIndexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(selectionIndex + 1)];
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            CGFloat height = self.selectionIndexLabel.font.pointSize + 8;
            [self.selectionIndexLabel autoSetDimension:ALDimensionHeight toSize:height];
            [self.selectionIndexLabel autoConstrainAttribute:ALAttributeWidth toAttribute:ALAttributeHeight ofView:self.selectionIndexLabel];
        }];
        
        [self.selectionIndexLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.selectionIndexLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        [self.checkmark autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [self.checkmark autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}


#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.selectionIndexLabel.text;
}


@end
