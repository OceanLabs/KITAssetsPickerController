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
#import "KITAssetScrollView.h"
#import "KITAssetPlayButton.h"
#import "NSBundle+KITAssetsPickerController.h"
#import "UIImage+KITAssetsPickerController.h"




NSString * const KITAssetScrollViewDidTapNotification = @"KITAssetScrollViewDidTapNotification";


@interface KITAssetScrollView ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<KITAssetDataSource> asset;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL didLoadPlayerItem;

@property (nonatomic, assign) CGFloat perspectiveZoomScale;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) KITAssetSelectionButton *selectionButton;

@property (nonatomic, assign) BOOL shouldUpdateConstraints;
@property (nonatomic, assign) BOOL didSetupConstraints;


@end





@implementation KITAssetScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _shouldUpdateConstraints            = YES;
        self.allowsSelection                = NO;
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom                    = YES;
        self.decelerationRate               = UIScrollViewDecelerationRateFast;
        self.delegate                       = self;
        
        [self setupViews];
        [self addGestureRecognizers];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupViews
{
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    self.imageView = imageView;
    [self addSubview:self.imageView];
    
    UIProgressView *progressView =
    [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView = progressView;
    [self addSubview:self.progressView];
    
    UIActivityIndicatorView *activityView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView = activityView;
    [self addSubview:self.activityView];
    
    KITAssetSelectionButton *selectionButton = [KITAssetSelectionButton newAutoLayoutView];
    self.selectionButton = selectionButton;
    [self addSubview:self.selectionButton];
}


#pragma mark - Update auto layout constraints

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self updateSelectionButtonIfNeeded];
        [self autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self updateProgressConstraints];
        [self updateActivityConstraints];
        [self updateButtonsConstraints];
        
        self.didSetupConstraints = YES;
    }

    [self updateContentFrame];
    [super updateConstraints];
}

- (void)updateSelectionButtonIfNeeded
{
    if (!self.allowsSelection)
    {
        [self.selectionButton removeFromSuperview];
        self.selectionButton = nil;
    }
}

- (void)updateProgressConstraints
{
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
        [self.progressView autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.superview withMultiplier:1 relation:NSLayoutRelationEqual];
        [self.progressView autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeTrailing ofView:self.superview withMultiplier:1 relation:NSLayoutRelationEqual];
        [self.progressView autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeBottom ofView:self.superview withMultiplier:1 relation:NSLayoutRelationEqual];
    }];
    
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
        [self.progressView autoConstrainAttribute:ALAttributeLeading toAttribute:ALAttributeLeading ofView:self.imageView withMultiplier:1 relation:NSLayoutRelationGreaterThanOrEqual];
        [self.progressView autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeTrailing ofView:self.imageView withMultiplier:1 relation:NSLayoutRelationLessThanOrEqual];
        [self.progressView autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeBottom ofView:self.imageView withMultiplier:1 relation:NSLayoutRelationLessThanOrEqual];
    }];
}

- (void)updateActivityConstraints
{
    [self.activityView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.superview];
    [self.activityView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.superview];
}

- (void)updateButtonsConstraints
{
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
        [self.selectionButton autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeTrailing ofView:self.superview withOffset:-8 relation:NSLayoutRelationEqual];
        [self.selectionButton autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeBottom ofView:self.superview withOffset:-8 relation:NSLayoutRelationEqual];
    }];
    
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
        [self.selectionButton autoConstrainAttribute:ALAttributeTrailing toAttribute:ALAttributeTrailing ofView:self.imageView withOffset:-8 relation:NSLayoutRelationLessThanOrEqual];
        [self.selectionButton autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeBottom ofView:self.imageView withOffset:-8 relation:NSLayoutRelationLessThanOrEqual];
    }];
}

- (void)updateContentFrame
{
    CGSize boundsSize = self.bounds.size;
    
    CGFloat w = self.zoomScale * self.asset.pixelWidth;
    CGFloat h = self.zoomScale * self.asset.pixelHeight;
    
    CGFloat dx = (boundsSize.width - w) / 2.0;
    CGFloat dy = (boundsSize.height - h) / 2.0;

    self.contentOffset = CGPointZero;
    self.imageView.frame = CGRectMake(dx, dy, w, h);
}



#pragma mark - Start/stop loading animation

- (void)startActivityAnimating
{
    [self.selectionButton setHidden:YES];
    [self.activityView startAnimating];
}

- (void)stopActivityAnimating
{
    [self.selectionButton setHidden:NO];
    [self.activityView stopAnimating];
}


#pragma mark - Set progress

- (void)setProgress:(CGFloat)progress
{
#if !defined(CT_APP_EXTENSIONS)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(progress < 1)];
#endif
    [self.progressView setProgress:progress animated:(progress < 1)];
    [self.progressView setHidden:(progress == 1)];
}

// To mimic image downloading progress
- (void)mimicProgress
{
    CGFloat progress = self.progressView.progress;

    if (progress < 0.95)
    {
        int lowerbound = progress * 100 + 1;
        int upperbound = 95;
        
        int random = lowerbound + arc4random() % (upperbound - lowerbound);
        CGFloat randomProgress = random / 100.0f;

        [self setProgress:randomProgress];
        
        NSInteger randomDelay = 1 + arc4random() % (3 - 1);
        [self performSelector:@selector(mimicProgress) withObject:nil afterDelay:randomDelay];
    }
}


#pragma mark - asset size

- (CGSize)assetSize
{
    return CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
}


#pragma mark - Bind asset image

- (void)bind:(id<KITAssetDataSource> )asset image:(UIImage *)image requestInfo:(NSDictionary *)info
{
    self.asset = asset;
    
    
    if (self.image == nil)
    {
        BOOL zoom = (!self.image);
        self.image = image;
        self.imageView.image = image;
        
        [self setProgress:1];
        
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self updateZoomScalesAndZoom:zoom];
    }
}


#pragma mark - Upate zoom scales

- (void)updateZoomScalesAndZoom:(BOOL)zoom
{
    if (!self.asset)
        return;
    
    CGSize assetSize    = [self assetSize];
    CGSize boundsSize   = self.bounds.size;
    
    CGFloat xScale = boundsSize.width / assetSize.width;    //scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / assetSize.height;  //scale needed to perfectly fit the image height-wise
    
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = 3.0 * minScale;
    
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
    
    
    // update perspective zoom scale
    self.perspectiveZoomScale = (boundsSize.width > boundsSize.height) ? xScale : yScale;
    
    if (zoom)
        [self zoomToInitialScale];
}



#pragma mark - Zoom

- (void)zoomToInitialScale
{
    if ([self canPerspectiveZoom])
        [self zoomToPerspectiveZoomScaleAnimated:NO];
    else
        [self zoomToMinimumZoomScaleAnimated:NO];
}

- (void)zoomToMinimumZoomScaleAnimated:(BOOL)animated
{
    [self setZoomScale:self.minimumZoomScale animated:animated];
}

- (void)zoomToMaximumZoomScaleWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    CGRect zoomRect = [self zoomRectWithScale:self.maximumZoomScale withCenter:[recognizer locationInView:recognizer.view]];

    self.shouldUpdateConstraints = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self zoomToRect:zoomRect animated:NO];
        
        CGRect frame = self.imageView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;

        self.imageView.frame = frame;
    }];
}


#pragma mark - Perspective zoom

- (BOOL)canPerspectiveZoom
{
    CGSize assetSize    = [self assetSize];
    CGSize boundsSize   = self.bounds.size;
    
    CGFloat assetRatio  = assetSize.width / assetSize.height;
    CGFloat boundsRatio = boundsSize.width / boundsSize.height;
    
    // can perform perspective zoom when the difference of aspect ratios is smaller than 20%
    return (fabs( (assetRatio - boundsRatio) / boundsRatio ) < 0.2f);
}

- (void)zoomToPerspectiveZoomScaleAnimated:(BOOL)animated;
{
    CGRect zoomRect = [self zoomRectWithScale:self.perspectiveZoomScale];
    [self zoomToRect:zoomRect animated:animated];
}

- (CGRect)zoomRectWithScale:(CGFloat)scale
{
    CGSize targetSize;
    targetSize.width    = self.bounds.size.width / scale;
    targetSize.height   = self.bounds.size.height / scale;
    
    CGPoint targetOrigin;
    targetOrigin.x      = (self.asset.pixelWidth - targetSize.width) / 2.0;
    targetOrigin.y      = (self.asset.pixelHeight - targetSize.height) / 2.0;
    
    CGRect zoomRect;
    zoomRect.origin = targetOrigin;
    zoomRect.size   = targetSize;

    return zoomRect;
}


#pragma mark - Zoom with gesture recognizer

- (void)zoomWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (self.minimumZoomScale == self.maximumZoomScale)
        return;
    
    if ([self canPerspectiveZoom])
    {
        if ((self.zoomScale >= self.minimumZoomScale && self.zoomScale < self.perspectiveZoomScale) ||
            (self.zoomScale <= self.maximumZoomScale && self.zoomScale > self.perspectiveZoomScale))
            [self zoomToPerspectiveZoomScaleAnimated:YES];
        else
            [self zoomToMaximumZoomScaleWithGestureRecognizer:recognizer];
        
        return;
    }
    
    if (self.zoomScale < self.maximumZoomScale)
        [self zoomToMaximumZoomScaleWithGestureRecognizer:recognizer];
    else
        [self zoomToMinimumZoomScaleAnimated:YES];
}

- (CGRect)zoomRectWithScale:(CGFloat)scale withCenter:(CGPoint)center
{
    center = [self.imageView convertPoint:center fromView:self];
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width  = self.imageView.frame.size.width  / scale;
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}


#pragma mark - Gesture recognizers

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapping:)];
    
    [doubleTap setNumberOfTapsRequired:2.0];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [singleTap setDelegate:self];
    [doubleTap setDelegate:self];
    
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
}


#pragma mark - Handle tappings

- (void)handleTapping:(UITapGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KITAssetScrollViewDidTapNotification object:recognizer];
    
    if (recognizer.numberOfTapsRequired == 2)
        [self zoomWithGestureRecognizer:recognizer];
}


#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.shouldUpdateConstraints = YES;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setScrollEnabled:(self.zoomScale != self.perspectiveZoomScale)];
    
    if (self.shouldUpdateConstraints)
    {
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }
}


#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return !([touch.view isDescendantOfView:self.selectionButton]);
}


#pragma mark - Notification observer

- (void)addPlayerNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(applicationWillResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
}

- (void)removePlayerNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


@end
