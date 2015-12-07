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



@interface KITAssetItemViewController ()

@property (nonatomic, weak) KITAssetsPickerController *picker;

@property (nonatomic, strong) id<KITAssetDataSource> asset;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) KITAssetScrollView *scrollView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end





@implementation KITAssetItemViewController

+ (KITAssetItemViewController *)assetItemViewControllerForAsset:(id<KITAssetDataSource> )asset
{
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(id<KITAssetDataSource> )asset
{
    if (self = [super init])
    {
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
    return (KITAssetsPickerController *)self.navigationController.parentViewController;
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
    KITAssetSelectionButton *selectionButton = self.scrollView.selectionButton;

    selectionButton.enabled  = [self assetScrollView:self.scrollView shouldEnableAsset:self.asset];
    selectionButton.selected = [self.picker.selectedAssets containsObject:self.asset];

    [selectionButton addTarget:self action:@selector(selectionButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [selectionButton addTarget:self action:@selector(selectionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Request image

- (void)requestAssetImage
{
    [self.scrollView setProgress:0];
    
    [self.asset dataWithCompletionHandler:^(NSData *data, NSError *error){
        self.image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView bind:self.asset image:self.image requestInfo:@{}];
        });
    }];
}

- (CGSize)targetImageSize
{
    UIScreen *screen    = UIScreen.mainScreen;
    CGFloat scale       = screen.scale;
    return CGSizeMake(CGRectGetWidth(screen.bounds) * scale, CGRectGetHeight(screen.bounds) * scale);
}


#pragma mark - Request error

- (void)showRequestImageError:(NSError *)error title:(NSString *)title
{
    [self.scrollView setProgress:1];
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


#pragma mark - Selection

- (void)selectionButtonTouchDown:(id)sender
{
    id<KITAssetDataSource> asset = self.asset;
    KITAssetScrollView *scrollView = self.scrollView;
    
    if ([self assetScrollView:scrollView shouldHighlightAsset:asset])
        [self assetScrollView:scrollView didHighlightAsset:asset];
}

- (void)selectionButtonTouchUpInside:(id)sender
{
    id<KITAssetDataSource> asset = self.asset;
    KITAssetScrollView *scrollView = self.scrollView;
    KITAssetSelectionButton *selectionButton = scrollView.selectionButton;
    
    
    if (!selectionButton.selected)
    {
        if ([self assetScrollView:scrollView shouldSelectAsset:asset])
        {
            [self.picker selectAsset:asset];
            [selectionButton setSelected:YES];
            [self assetScrollView:scrollView didSelectAsset:asset];
        }
    }
    
    else
    {
        if ([self assetScrollView:scrollView shouldDeselectAsset:asset])
        {
            [self.picker deselectAsset:asset];
            [selectionButton setSelected:NO];
            [self assetScrollView:scrollView didDeselectAsset:asset];
        }
    }
    
    [self assetScrollView:self.scrollView didUnhighlightAsset:self.asset];
}


#pragma mark - Asset scrollView delegate

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldEnableAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        return YES;
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldSelectAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didSelectAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldDeselectAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didDeselectAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}

- (BOOL)assetScrollView:(KITAssetScrollView *)scrollView shouldHighlightAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didHighlightAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)assetScrollView:(KITAssetScrollView *)scrollView didUnhighlightAsset:(id<KITAssetDataSource> )asset
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}


@end
