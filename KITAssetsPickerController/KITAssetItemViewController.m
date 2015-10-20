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
#import "KITAssetsPickerController.h"
#import "KITAssetItemViewController.h"
#import "KITAssetScrollView.h"
#import "NSBundle+KITAssetsPickerController.h"
#import "PHAsset+KITAssetsPickerController.h"




@interface KITAssetItemViewController ()

@property (nonatomic, weak) KITAssetsPickerController *picker;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) PHImageRequestID playerItemRequestID;
@property (nonatomic, strong) KITAssetScrollView *scrollView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end





@implementation KITAssetItemViewController

+ (KITAssetItemViewController *)assetItemViewControllerForAsset:(PHAsset *)asset
{
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(PHAsset *)asset
{
    if (self = [super init])
    {
        _imageManager = [PHImageManager defaultManager];
        self.asset = asset;
        self.allowsSelection = NO;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScrollViewButtons];
    [self requestAssetImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseAsset:self.view];
    [self cancelRequestAsset];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.scrollView setNeedsUpdateConstraints];
    [self.scrollView updateConstraintsIfNeeded];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.scrollView updateZoomScalesAndZoom:YES];
    } completion:nil];
}


#pragma mark - Accessors

- (KITAssetsPickerController *)picker
{
    return (KITAssetsPickerController *)self.splitViewController.parentViewController;
}


#pragma mark - Setup

- (void)setupViews
{
    KITAssetScrollView *scrollView = [KITAssetScrollView newAutoLayoutView];
    scrollView.allowsSelection = self.allowsSelection;
    
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
    [self.view layoutIfNeeded];
}

- (void)setupScrollViewButtons
{
    KITAssetPlayButton *playButton = self.scrollView.playButton;
    [playButton addTarget:self action:@selector(playAsset:) forControlEvents:UIControlEventTouchUpInside];
    
    KITAssetSelectionButton *selectionButton = self.scrollView.selectionButton;

    selectionButton.enabled  = [self assetScrollView:self.scrollView shouldEnableAsset:self.asset];
    selectionButton.selected = [self.picker.selectedAssets containsObject:self.asset];

    [selectionButton addTarget:self action:@selector(selectionButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [selectionButton addTarget:self action:@selector(selectionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Cancel request

- (void)cancelRequestAsset
{
    [self cancelRequestImage];
    [self cancelRequestPlayerItem];
}

- (void)cancelRequestImage
{
    if (self.imageRequestID)
    {
        [self.scrollView setProgress:1];
        [self.imageManager cancelImageRequest:self.imageRequestID];
    }
}

- (void)cancelRequestPlayerItem
{
    if (self.playerItemRequestID)
    {
        [self.scrollView stopActivityAnimating];
        [self.imageManager cancelImageRequest:self.playerItemRequestID];
    }
}


#pragma mark - Request image

- (void)requestAssetImage
{
    [self.scrollView setProgress:0];
    
    CGSize targetSize = [self targetImageSize];
    PHImageRequestOptions *options = [self imageRequestOptions];
    
    self.imageRequestID =
    [self.imageManager requestImageForAsset:self.asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *image, NSDictionary *info) {

                                  // this image is set for transition animation
                                  self.image = image;
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                      NSError *error = [info objectForKey:PHImageErrorKey];
                                      
                                      if (error)
                                          [self showRequestImageError:error title:nil];
                                      else
                                          [self.scrollView bind:self.asset image:image requestInfo:info];
                                  });
                              }];
}

- (CGSize)targetImageSize
{
    UIScreen *screen    = UIScreen.mainScreen;
    CGFloat scale       = screen.scale;
    return CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
}

- (PHImageRequestOptions *)imageRequestOptions
{
    PHImageRequestOptions *options  = [PHImageRequestOptions new];
    options.networkAccessAllowed    = YES;
    options.progressHandler         = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setProgress:progress];
        });
    };
    
    return options;
}


#pragma mark - Request player item

- (void)requestAssetPlayerItem:(id)sender
{
    [self.scrollView startActivityAnimating];
    
    PHVideoRequestOptions *options = [self videoRequestOptions];
    
    self.playerItemRequestID =
    [self.imageManager requestPlayerItemForVideo:self.asset
                                         options:options
                                   resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           NSError *error   = [info objectForKey:PHImageErrorKey];
                                           NSString * title = KITAssetsPickerLocalizedString(@"Cannot Play Stream Video", nil);
                                           
                                           if (error)
                                               [self showRequestVideoError:error title:title];
                                           else
                                               [self.scrollView bind:playerItem requestInfo:info];
                                       });
                                   }];
}

- (PHVideoRequestOptions *)videoRequestOptions
{
    PHVideoRequestOptions *options  = [PHVideoRequestOptions new];
    options.networkAccessAllowed    = YES;
    options.progressHandler         = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //do nothing
        });
    };
    
    return options;
}


#pragma mark - Request error

- (void)showRequestImageError:(NSError *)error title:(NSString *)title
{
    [self.scrollView setProgress:1];
    [self showRequestError:error title:title];
}

- (void)showRequestVideoError:(NSError *)error title:(NSString *)title
{
    [self.scrollView stopActivityAnimating];
    [self showRequestError:error title:title];
}

- (void)showRequestError:(NSError *)error title:(NSString *)title
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action =
    [UIAlertAction actionWithTitle:KITAssetsPickerLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Playback

- (void)playAsset:(id)sender
{
    if (!self.scrollView.player)
        [self requestAssetPlayerItem:sender];
    else
        [self.scrollView playVideo];
}

- (void)pauseAsset:(id)sender
{
    if (!self.scrollView.player)
        [self cancelRequestPlayerItem];
    else
        [self.scrollView pauseVideo];
}


#pragma mark - Selection

- (void)selectionButtonTouchDown:(id)sender
{
    PHAsset *asset = self.asset;
    KITAssetScrollView *scrollView = self.scrollView;
    
    if ([self assetScrollView:scrollView shouldHighlightAsset:asset])
        [self assetScrollView:scrollView didHighlightAsset:asset];
}

- (void)selectionButtonTouchUpInside:(id)sender
{
    PHAsset *asset = self.asset;
    KITAssetScrollView *scrollView = self.scrollView;
    KITAssetSelectionButton *selectionButton = scrollView.selectionButton;
    
    
    if (!selectionButton.selected)
    {
        if ([self assetScrollView:scrollView shouldSeleKITAsset:asset])
        {
            [self.picker seleKITAsset:asset];
            [selectionButton setSelected:YES];
            [self assetScrollView:scrollView didSeleKITAsset:asset];
        }
    }
    
    else
    {
        if ([self assetScrollView:scrollView shouldDeseleKITAsset:asset])
        {
            [self.picker deseleKITAsset:asset];
            [selectionButton setSelected:NO];
            [self assetScrollView:scrollView didDeseleKITAsset:asset];
        }
    }
    
    [self assetScrollView:self.scrollView didUnhighlightAsset:self.asset];
}


#pragma mark - Asset scrollView delegate

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldEnableAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        return YES;
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldSeleKITAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSeleKITAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSeleKITAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didSeleKITAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSeleKITAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didSeleKITAsset:asset];
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldDeseleKITAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeseleKITAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeseleKITAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didDeseleKITAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeseleKITAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didDeseleKITAsset:asset];
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldHighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didHighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didUnhighlightAsset:(PHAsset *)asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}


@end
