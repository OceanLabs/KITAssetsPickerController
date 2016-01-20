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
#import "KITAssetsPickerAccessDeniedView.h"
#import "KITAssetsPickerNoAssetsView.h"
#import "KITAssetCollectionViewController.h"
#import "KITAssetsGridViewController.h"
#import "KITAssetScrollView.h"
#import "KITAssetsPageViewController.h"
#import "KITAssetsViewControllerTransition.h"
#import "NSBundle+KITAssetsPickerController.h"
#import "UIImage+KITAssetsPickerController.h"
#import "NSNumberFormatter+KITAssetsPickerController.h"




NSString * const KITAssetsPickerSelectedAssetsDidChangeNotification = @"KITAssetsPickerSelectedAssetsDidChangeNotification";
NSString * const KITAssetsPickerDidSelectAssetNotification = @"KITAssetsPickerDidSelectAssetNotification";
NSString * const KITAssetsPickerDidDeselectAssetNotification = @"KITAssetsPickerDidDeselectAssetNotification";



@interface KITAssetsPickerController ()
<UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL shouldCollapseDetailViewController;

@property (nonatomic, assign) CGSize assetCollectionThumbnailSize;
@property (nonatomic, assign) CGSize assetThumbnailSize;

@end



@implementation KITAssetsPickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _shouldCollapseDetailViewController = YES;
        _assetCollectionThumbnailSize       = KITAssetCollectionThumbnailSize;
        _selectedAssets                     = [NSMutableArray new];
        _showsCancelButton                  = YES;
        _showsEmptyAlbums                   = YES;
        _showsNumberOfAssets                = YES;
        _showsSelectionIndex                = NO;
        
        self.preferredContentSize           = KITAssetsPickerPopoverContentSize;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupEmptyViewController];
    [self checkAssetsCount];
    [self addKeyValueObserver];
}

- (void)dealloc
{
    [self removeKeyValueObserver];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.navigationController.viewControllers.firstObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    UIViewController *vc = self.navigationController.viewControllers.lastObject;
    
    if ([vc isMemberOfClass:[UINavigationController class]])
        return ((UINavigationController *)vc).topViewController;
    else
        return nil;
}

#pragma mark - Check assets count

- (void)checkAssetsCount
{
    if (self.collectionDataSources.count > 0) {
        [self showAssetCollectionViewController];
    } else {
        [self showNoAssets];
    }
}


#pragma mark - Setup views

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
}


#pragma mark - Setup view controllers

- (void)setupEmptyViewController
{
    UINavigationController *nav = [self emptyNavigationController];
    [self setupChildViewController:nav];
}

- (void)setupSplitViewController
{
    UIViewController *vc;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=8 && self.collectionDataSources.count > 1){
        
        vc = [KITAssetCollectionViewController new];
    }
    else{
        vc = [KITAssetsGridViewController new];
        ((KITAssetsGridViewController *)vc).assetCollection = self.collectionDataSources.firstObject;
    }
    
    UINavigationController *master = [[UINavigationController alloc] initWithRootViewController:vc];
    
    master.interactivePopGestureRecognizer.enabled  = YES;
    master.interactivePopGestureRecognizer.delegate = nil;
    
    [master willMoveToParentViewController:self];
    [master.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:master.view];
    [self addChildViewController:master];
    [master didMoveToParentViewController:self];
    
    if ([vc respondsToSelector:@selector(reloadUserInterface)]){
        [(KITAssetCollectionViewController *)vc reloadUserInterface];
    }
}

- (void)setupChildViewController:(UIViewController *)vc
{
    [vc willMoveToParentViewController:self];
    [vc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
}

- (void)removeChildViewController
{
    UIViewController *vc = self.childViewControllers.firstObject;
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

#pragma mark - Setup view controllers

- (UINavigationController *)emptyNavigationController
{
    UIViewController *vc = [self emptyViewController];
    return [[UINavigationController alloc] initWithRootViewController:vc];
}

- (UIViewController *)emptyViewController
{
    UIViewController *vc                = [UIViewController new];
    vc.view.backgroundColor             = [UIColor whiteColor];
    vc.navigationItem.hidesBackButton   = YES;
 
    return vc;
}




#pragma mark - Show asset collection view controller

- (void)showAssetCollectionViewController
{
    [self removeChildViewController];
    [self setupSplitViewController];
}


#pragma mark - Show auxiliary view

- (void)showAuxiliaryView:(UIView *)view
{
    [self removeChildViewController];

    UIViewController *vc = [self emptyViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [vc.view addSubview:view];
    [view setNeedsUpdateConstraints];
    [view updateConstraintsIfNeeded];
    
    [self setupButtonInViewController:vc];
    [self setupChildViewController:nav];
}


#pragma mark - Access denied

- (void)showAccessDenied
{
    [self showAuxiliaryView:[KITAssetsPickerAccessDeniedView new]];
}


#pragma mark - No Assets

- (void)showNoAssets
{
    [self showAuxiliaryView:[KITAssetsPickerNoAssetsView new]];
}


#pragma mark - Cancel button

- (void)setupButtonInViewController:(UIViewController *)viewController
{
    if (self.showsCancelButton)
    {
        viewController.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:KITAssetsPickerLocalizedString(@"Cancel", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(dismiss:)];
    }
}


#pragma mark - Key-Value observer

- (void)addKeyValueObserver
{
    [self addObserver:self
           forKeyPath:@"selectedAssets"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];
}

- (void)removeKeyValueObserver
{
    @try {
        [self removeObserver:self forKeyPath:@"selectedAssets"];
    }
    @catch (NSException *exception) {
        // do nothing
    }
}


#pragma mark - Key-Value changed

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selectedAssets"])
    {
        [self toggleDoneButton];
        [self postSelectedAssetsDidChangeNotification:[object valueForKey:keyPath]];
    }
}


#pragma mark - Toggle button

- (void)toggleDoneButton
{
    UIViewController *vc = self.childNavigationViewController.viewControllers.firstObject;
    
    if ([vc isMemberOfClass:[UINavigationController class]])
    {
        BOOL enabled = (self.selectedAssets.count > 0);
        
        for (UIViewController *viewController in ((UINavigationController *)vc).viewControllers)
            viewController.navigationItem.rightBarButtonItem.enabled = enabled;
    }
}


#pragma mark - Post notifications

- (void)postSelectedAssetsDidChangeNotification:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KITAssetsPickerSelectedAssetsDidChangeNotification
                                                        object:sender];
}

- (void)postDidSelectAssetNotification:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KITAssetsPickerDidSelectAssetNotification
                                                        object:sender];
}

- (void)postDidDeselectAssetNotification:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KITAssetsPickerDidDeselectAssetNotification
                                                        object:sender];
}


#pragma mark - Accessors

- (UINavigationController *)childNavigationViewController
{
    return (UINavigationController *)self.childViewControllers.firstObject;
}


#pragma mark - Indexed accessors

- (NSUInteger)countOfSelectedAssets
{
    return self.selectedAssets.count;
}

- (instancetype)objectInSelectedAssetsAtIndex:(NSUInteger)index
{
    return [self.selectedAssets objectAtIndex:index];
}

- (void)insertObject:(id)object inSelectedAssetsAtIndex:(NSUInteger)index
{
    [self.selectedAssets insertObject:object atIndex:index];
}

- (void)removeObjectFromSelectedAssetsAtIndex:(NSUInteger)index
{
    [self.selectedAssets removeObjectAtIndex:index];
}

- (void)replaceObjectInSelectedAssetsAtIndex:(NSUInteger)index withObject:(id<KITAssetDataSource> )object
{
    [self.selectedAssets replaceObjectAtIndex:index withObject:object];
}


#pragma mark - De/Select asset

- (void)selectAsset:(id<KITAssetDataSource> )asset
{
    [self insertObject:asset inSelectedAssetsAtIndex:self.countOfSelectedAssets];
    [self postDidSelectAssetNotification:asset];
}

- (void)deselectAsset:(id<KITAssetDataSource> )asset
{
    [self removeObjectFromSelectedAssetsAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self postDidDeselectAssetNotification:asset];
}


#pragma mark - Selected assets string

- (NSString *)selectedAssetsString
{
    if (self.selectedAssets.count == 0)
        return nil;
            
    NSString *format;
    
    format = (self.selectedAssets.count > 1) ?
    KITAssetsPickerLocalizedString(@"%@ Photos Selected", nil) :
    KITAssetsPickerLocalizedString(@"%@ Photo Selected", nil);
    
    NSNumberFormatter *nf = [NSNumberFormatter new];
    
    return [NSString stringWithFormat:format, [nf KITAssetsPickerStringFromAssetsCount:self.selectedAssets.count]];
}


#pragma mark - Image target size

- (CGSize)imageSizeForContainerSize:(CGSize)size
{
    CGFloat scale = UIScreen.mainScreen.scale;
    return CGSizeMake(size.width * scale, size.height * scale);
}




#pragma mark - Navigation controller delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ((operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[KITAssetsPageViewController class]]) ||
        (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[KITAssetsPageViewController class]]))
    {
        KITAssetsViewControllerTransition *transition = [[KITAssetsViewControllerTransition alloc] init];
        transition.operation = operation;

        return transition;
    }
    else
    {
        return nil;
    }
}


#pragma mark - Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [self.delegate assetsPickerControllerDidCancel:self];
    else
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
}


@end