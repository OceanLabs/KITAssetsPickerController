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
#import "KITAssetsPickerNoAssetsView.h"
#import "NSBundle+KITAssetsPickerController.h"



@interface KITAssetsPickerNoAssetsView ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *message;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end;


@implementation KITAssetsPickerNoAssetsView

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
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    CGFloat size = descriptor.pointSize * 1.7;
    
    UILabel *title      = [UILabel new];
    title.textColor     = KITAssetsPickerNoAssetsViewTextColor;
    title.font          = [UIFont fontWithDescriptor:descriptor size:size];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 5;
    title.text          = KITAssetsPickerLocalizedString(@"No Photos", nil);
    self.title = title;
    
    UILabel *message        = [UILabel new];
    message.textColor       = KITAssetsPickerNoAssetsViewTextColor;
    message.font            = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    message.text            = [self noAssetsMessage];
    self.message = message;
    
    [self addSubview:self.title];
    [self addSubview:self.message];
}

- (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
}

- (BOOL)isCameraDeviceAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (NSString *)noAssetsMessage
{
    NSString *format;
    
    if ([self isCameraDeviceAvailable])
        format = KITAssetsPickerLocalizedString(@"", nil);
    else
        format = KITAssetsPickerLocalizedString(@"", nil);
    
    return [NSString stringWithFormat:format, self.deviceModel];
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self autoCenterInSuperview];
        [self autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        
        [self.title autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.title autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        
        [self.message autoAlignAxis:ALAxisVertical toSameAxisOfView:self.title];
        [self.message autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.title withOffset:10];
        [self.message autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}


@end
