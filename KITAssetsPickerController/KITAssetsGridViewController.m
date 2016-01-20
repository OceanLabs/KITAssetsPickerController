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

#import "KITAssetsPickerDefines.h"
#import "KITAssetsPickerController.h"
#import "KITAssetsPickerController+Internal.h"
#import "KITAssetsGridViewController.h"
#import "KITAssetsGridView.h"
#import "KITAssetsGridViewLayout.h"
#import "KITAssetsGridViewCell.h"
#import "KITAssetsGridViewFooter.h"
#import "KITAssetsPickerNoAssetsView.h"
#import "KITAssetsPageViewController.h"
#import "KITAssetsPageViewController+Internal.h"
#import "KITAssetsViewControllerTransition.h"
#import "UICollectionView+KITAssetsPickerController.h"
#import "NSIndexSet+KITAssetsPickerController.h"
#import "NSBundle+KITAssetsPickerController.h"




NSString * const KITAssetsGridViewCellIdentifier = @"KITAssetsGridViewCellIdentifier";
NSString * const KITAssetsGridViewFooterIdentifier = @"KITAssetsGridViewFooterIdentifier";


@interface KITAssetsGridViewController ()

@property (nonatomic, weak) KITAssetsPickerController *picker;

@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, assign) CGRect previousBounds;

@property (nonatomic, strong) KITAssetsGridViewFooter *footer;
@property (nonatomic, strong) KITAssetsPickerNoAssetsView *noAssetsView;

@property (nonatomic, assign) BOOL didLayoutSubviews;

@end





@implementation KITAssetsGridViewController


- (instancetype)init
{
    KITAssetsGridViewLayout *layout = [KITAssetsGridViewLayout new];
    
    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        self.collectionView.allowsMultipleSelection = YES;
        
        [self.collectionView registerClass:KITAssetsGridViewCell.class
                forCellWithReuseIdentifier:KITAssetsGridViewCellIdentifier];
        
        [self.collectionView registerClass:KITAssetsGridViewFooter.class
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:KITAssetsGridViewFooterIdentifier];
        
        [self addNotificationObserver];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self addGestureRecognizer];
    [self addNotificationObserver];
    [self resetCachedAssetImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssets];
    [self setupButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssetImages];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGRectEqualToRect(self.view.bounds, self.previousBounds))
    {
        [self updateCollectionViewLayout];
        self.previousBounds = self.view.bounds;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.didLayoutSubviews && self.assetCollection.count > 0)
    {
        [self scrollToBottomIfNeeded];
        self.didLayoutSubviews = YES;
    }
}

- (void)updateButton:(NSArray *)selectedAssets
{
        self.navigationItem.rightBarButtonItem.enabled = (self.picker.selectedAssets.count > 0);
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Accessors

- (KITAssetsPickerController *)picker
{
    return (KITAssetsPickerController *)self.navigationController.parentViewController;
}

- (id<KITAssetDataSource> )assetAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.assetCollection.count > 0) ? [self.assetCollection objectAtIndex:indexPath.item] : nil;
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    KITAssetsGridView *gridView = [KITAssetsGridView new];
    [self.view insertSubview:gridView atIndex:0];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupButtons
{
    if (self.navigationController.viewControllers.count == 1){
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:KITAssetsPickerLocalizedString(@"Cancel", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self.picker
                                        action:@selector(dismiss:)];
    }
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:KITAssetsPickerLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStyleDone
                                    target:self.picker
                                    action:@selector(finishPickingAssets:)];
    [self updateButton:self.picker.selectedAssets];
}

- (void)setupAssets
{
    [self reloadData];
}




#pragma mark - Collection view layout

- (void)updateCollectionViewLayout
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        UITraitCollection *trait = self.traitCollection;
        CGSize contentSize = self.view.bounds.size;
        UICollectionViewLayout *layout;
        
        if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:collectionViewLayoutForContentSize:traitCollection:)]) {
            layout = [self.picker.delegate assetsPickerController:self.picker collectionViewLayoutForContentSize:contentSize traitCollection:trait];
        } else {
            layout = [[KITAssetsGridViewLayout alloc] initWithContentSize:contentSize traitCollection:trait];
        }
        
        __weak KITAssetsGridViewController *weakSelf = self;
        
        [self.collectionView setCollectionViewLayout:layout animated:NO completion:^(BOOL finished){
            [weakSelf.collectionView reloadItemsAtIndexPaths:[weakSelf.collectionView indexPathsForVisibleItems]];
        }];
    }
}



#pragma mark - Scroll to bottom

- (void)scrollToBottomIfNeeded
{
    BOOL shouldScrollToBottom;
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldScrollToBottomForAssetCollection:)])
        shouldScrollToBottom = [self.picker.delegate assetsPickerController:self.picker shouldScrollToBottomForAssetCollection:self.assetCollection];
    else
        shouldScrollToBottom = YES;
 
    if (shouldScrollToBottom)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.assetCollection.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}



#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(assetsPickerDidSelectAsset:)
                   name:KITAssetsPickerDidSelectAssetNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(assetsPickerDidDeselectAsset:)
                   name:KITAssetsPickerDidDeselectAssetNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:KITAssetsPickerDidSelectAssetNotification object:nil];
    [center removeObserver:self name:KITAssetsPickerDidDeselectAssetNotification object:nil];
}


#pragma mark - Did de/select asset notifications

- (void)assetsPickerDidSelectAsset:(NSNotification *)notification
{
    id<KITAssetDataSource> asset = (id<KITAssetDataSource> )notification.object;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.assetCollection indexOfObject:asset] inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self updateSelectionOrderLabels];
}

- (void)assetsPickerDidDeselectAsset:(NSNotification *)notification
{
    id<KITAssetDataSource> asset = (id<KITAssetDataSource> )notification.object;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.assetCollection indexOfObject:asset] inSection:0];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self updateSelectionOrderLabels];
}


#pragma mark - Update Selection Order Labels

- (void)updateSelectionOrderLabels
{
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems])
    {
        id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
        KITAssetsGridViewCell *cell = (KITAssetsGridViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.selectionIndex = [self.picker.selectedAssets indexOfObject:asset];
    }
}


#pragma mark - Gesture recognizer

- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pushPageViewController:)];
    
    [self.collectionView addGestureRecognizer:longPress];
}


#pragma mark - Push assets page view controller

- (void)pushPageViewController:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point           = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath  = [self.collectionView indexPathForItemAtPoint:point];
        
        KITAssetsPageViewController *vc = [[KITAssetsPageViewController alloc] initWithCollection:self.picker.collectionDataSources[indexPath.row]];
        vc.allowsSelection = YES;
        vc.pageIndex = indexPath.item;

        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Reload data

- (void)reloadData
{
    if (self.assetCollection.count > 0)
    {
        [self hideNoAssets];
        [self.collectionView reloadData];
    }
    else
    {
        [self showNoAssets];
    }
}


#pragma mark - Asset images caching

- (void)resetCachedAssetImages
{
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssetImages
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    
    if (!isViewVisible)
        return;
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f)
    {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self.collectionView KITAssetsPickerIndexPathsForElementsInRect:removedRect];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            } addedHandler:^(CGRect addedRect) {
                                NSArray *indexPaths = [self.collectionView KITAssetsPickerIndexPathsForElementsInRect:addedRect];
                                [addedIndexPaths addObjectsFromArray:indexPaths];
                            }];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}


#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssetImages];
}


#pragma mark - No assets

- (void)showNoAssets
{
    KITAssetsPickerNoAssetsView *view = [KITAssetsPickerNoAssetsView new];
    [self.view addSubview:view];
    [view setNeedsUpdateConstraints];
    [view updateConstraintsIfNeeded];
    
    self.noAssetsView = view;
}

- (void)hideNoAssets
{
    if (self.noAssetsView)
    {
        [self.noAssetsView removeFromSuperview];
        self.noAssetsView = nil;
    }
}


#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetCollection.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KITAssetsGridViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:KITAssetsGridViewCellIdentifier
                                              forIndexPath:indexPath];
    
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldEnableAsset:)])
        cell.enabled = [self.picker.delegate assetsPickerController:self.picker shouldEnableAsset:asset];
    else
        cell.enabled = YES;
    
    cell.showsSelectionIndex = self.picker.showsSelectionIndex;
    
    // XXX
    // Setting `selected` property blocks further deselection.
    // Have to call selectItemAtIndexPath too. ( ref: http://stackoverflow.com/a/17812116/1648333 )
    if ([self.picker.selectedAssets containsObject:asset])
    {
        cell.selected = YES;
        cell.selectionIndex = [self.picker.selectedAssets indexOfObject:asset];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [cell bind:asset];
    
    UICollectionViewLayoutAttributes *attributes =
    [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    
    CGSize targetSize = [self.picker imageSizeForContainerSize:attributes.size];
    
    [self requestThumbnailForCell:cell targetSize:targetSize asset:asset];

    return cell;
}

- (void)requestThumbnailForCell:(KITAssetsGridViewCell *)cell targetSize:(CGSize)targetSize asset:(id<KITAssetDataSource> )asset
{
    NSInteger tag = cell.tag + 1;
    cell.tag = tag;
    
    [asset thumbnailImageWithCompletionHandler:^(UIImage *image){
        if (cell.tag == tag){
            [(KITAssetThumbnailView *)cell.backgroundView bind:image asset:asset];
        }
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    KITAssetsGridViewFooter *footer =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                       withReuseIdentifier:KITAssetsGridViewFooterIdentifier
                                              forIndexPath:indexPath];
    
    [footer bind:self.assetCollection];
    
    self.footer = footer;
    
    return footer;
}


#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    KITAssetsGridViewCell *cell = (KITAssetsGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.isEnabled)
        return NO;
    else if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldSelectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    [self.picker selectAsset:asset];
    
    [self updateTitle:self.picker.selectedAssets];
    [self updateButton:self.picker.selectedAssets];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didSelectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didSelectAsset:asset];
}

- (void)updateTitle:(NSArray *)selectedAssets
{
    if ([self isTopViewController] && selectedAssets.count > 0)
        self.title = self.picker.selectedAssetsString;
    else
        [self resetTitle];
}

- (BOOL)isTopViewController
{
    UIViewController *vc = self.navigationController;
    
    if ([vc isMemberOfClass:[UINavigationController class]])
        return (self == ((UINavigationController *)vc).topViewController);
    else
        return NO;
}

- (void)resetTitle
{
    if (!self.picker.title)
        self.title = KITAssetsPickerLocalizedString(@"Photos", nil);
    else
        self.title = self.picker.title;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldDeselectAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldDeselectAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    [self.picker deselectAsset:asset];
    
    [self updateTitle:self.picker.selectedAssets];
    [self updateButton:self.picker.selectedAssets];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didDeselectAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didDeselectAsset:asset];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:shouldHighlightAsset:)])
        return [self.picker.delegate assetsPickerController:self.picker shouldHighlightAsset:asset];
    else
        return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didHighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didHighlightAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetDataSource> asset = [self assetAtIndexPath:indexPath];
    
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightAsset:)])
        [self.picker.delegate assetsPickerController:self.picker didUnhighlightAsset:asset];
}

@end