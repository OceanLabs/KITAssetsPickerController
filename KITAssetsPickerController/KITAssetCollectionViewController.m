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
#import "KITAssetCollectionViewController.h"
#import "KITAssetCollectionViewCell.h"
#import "KITAssetsGridViewController.h"
#import "NSBundle+KITAssetsPickerController.h"





@interface KITAssetCollectionViewController()
<KITAssetsGridViewControllerDelegate>

@property (nonatomic, weak) KITAssetsPickerController *picker;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSArray *fetchResults;
@property (nonatomic, copy) NSArray *assetCollections;

@property (nonatomic, strong) id<KITAssetCollectionDataSource> defaultAssetCollection;
@property (nonatomic, assign) BOOL didShowDefaultAssetCollection;
@property (nonatomic, assign) BOOL didSelectDefaultAssetCollection;

@end





@implementation KITAssetCollectionViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        [self addNotificationObserver];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self localize];
    [self setupFetchResults];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTitle:self.picker.selectedAssets];
    [self updateButton:self.picker.selectedAssets];
    [self selectDefaultAssetCollection];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8){
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resetTitle];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}


#pragma mark - Reload user interface

- (void)reloadUserInterface
{
    [self setupViews];
    [self setupButtons];
    [self localize];
    [self setupFetchResults];
}


#pragma mark - Accessors

- (KITAssetsPickerController *)picker
{
    return (KITAssetsPickerController *)self.navigationController.parentViewController;
}

- (NSIndexPath *)indexPathForAssetCollection:(id<KITAssetCollectionDataSource>)assetCollection
{
    NSInteger row = [self.assetCollections indexOfObject:assetCollection];

    if (row != NSNotFound)
        return [NSIndexPath indexPathForRow:row inSection:0];
    else
        return nil;
}


#pragma mark - Setup

- (void)setupViews
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.estimatedRowHeight =
    self.picker.assetCollectionThumbnailSize.height + 16;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupButtons
{
    self.cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:KITAssetsPickerLocalizedString(@"Cancel", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self.picker
                                    action:@selector(dismiss:)];

    self.doneButton =
    [[UIBarButtonItem alloc] initWithTitle:KITAssetsPickerLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStyleDone
                                    target:self.picker
                                    action:@selector(finishPickingAssets:)];
}

- (void)localize
{
    [self resetTitle];
}

- (void)setupFetchResults
{
    [self updateAssetCollections];
    [self reloadData];
    [self showDefaultAssetCollection];
}

- (void)updateAssetCollections
{
    NSMutableArray *assetCollections = [NSMutableArray new];

        for (id<KITAssetCollectionDataSource> assetCollection in self.picker.collectionDataSources)
        {
            NSInteger count = assetCollection.count;
            
            if (self.picker.showsEmptyAlbums || count > 0)
                [assetCollections addObject:assetCollection];
        }

    self.assetCollections = [NSMutableArray arrayWithArray:assetCollections];
}


#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateTitle:self.picker.selectedAssets];
        [self updateButton:self.picker.selectedAssets];
    } completion:nil];
}

#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:KITAssetsPickerSelectedAssetsDidChangeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contentSizeCategoryChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KITAssetsPickerSelectedAssetsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}


#pragma mark - Selected assets changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
    NSArray *selectedAssets = (NSArray *)notification.object;
    [self updateTitle:selectedAssets];
    [self updateButton:selectedAssets];
}

- (void)updateTitle:(NSArray *)selectedAssets
{
    if ([self isTopViewController] && selectedAssets.count > 0)
        self.title = self.picker.selectedAssetsString;
    else
        [self resetTitle];
}

- (void)updateButton:(NSArray *)selectedAssets
{
    self.navigationItem.leftBarButtonItem = (self.picker.showsCancelButton) ? self.cancelButton : nil;
    self.navigationItem.rightBarButtonItem = [self isTopViewController] ? self.doneButton : nil;
    
        self.navigationItem.rightBarButtonItem.enabled = (self.picker.selectedAssets.count > 0);
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


#pragma mark - Content size category changed

- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self reloadData];
}


#pragma mark - Reload data

- (void)reloadData
{
    if (self.assetCollections.count > 0)
        [self.tableView reloadData];
    else
        [self.picker showNoAssets];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetCollectionDataSource> collection = self.assetCollections[indexPath.row];
    NSUInteger count;
    
    if (self.picker.showsNumberOfAssets){
        count = [collection count];
    }
    else
        count = NSNotFound;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    KITAssetCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[KITAssetCollectionViewCell alloc] initWithThumbnailSize:self.picker.assetCollectionThumbnailSize
                                                            reuseIdentifier:cellIdentifier];
    
    [cell bind:collection count:count];
    [self requestThumbnailsForCell:cell assetCollection:collection];
    
    return cell;
}

- (void)requestThumbnailsForCell:(KITAssetCollectionViewCell *)cell assetCollection:(id<KITAssetCollectionDataSource>)collection
{
    NSUInteger count    = cell.thumbnailStacks.thumbnailViews.count;
    NSArray *assets     = [self posterAssetsFromAssetCollection:collection count:count];
//    CGSize targetSize   = [self.picker imageSizeForContainerSize:self.picker.assetCollectionThumbnailSize];
    
    for (NSUInteger index = 0; index < count; index++)
    {
        KITAssetThumbnailView *thumbnailView = [cell.thumbnailStacks thumbnailAtIndex:index];
        thumbnailView.hidden = (assets.count > 0) ? YES : NO;
        
        if (index < assets.count)
        {
            id<KITAssetDataSource> asset = assets[index];
            [asset thumbnailImageWithCompletionHandler:^(UIImage *image){
                [thumbnailView setHidden:NO];
                [thumbnailView bind:image assetCollection:collection];
            }];
        }
    }
}

- (NSArray *)posterAssetsFromAssetCollection:(id<KITAssetCollectionDataSource>)collection count:(NSUInteger)count;
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < MIN(count, collection.count); i++){
        [assets addObject:[collection objectAtIndex:i]];
    }
    return assets;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<KITAssetCollectionDataSource> collection = self.assetCollections[indexPath.row];
    
    KITAssetsGridViewController *vc = [KITAssetsGridViewController new];
    vc.assetCollection = collection;
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = (id<UINavigationControllerDelegate>)self.picker;
    
    [self.picker setShouldCollapseDetailViewController:NO];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Show / select default asset collection

- (void)showDefaultAssetCollection
{
    if (self.defaultAssetCollection && !self.didShowDefaultAssetCollection)
    {
        KITAssetsGridViewController *vc = [KITAssetsGridViewController new];
        vc.assetCollection = self.defaultAssetCollection;
        vc.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.delegate = (id<UINavigationControllerDelegate>)self.picker;
        
        [self.picker setShouldCollapseDetailViewController:NO];        
        [self.navigationController pushViewController:vc animated:YES];

        NSIndexPath *indexPath = [self indexPathForAssetCollection:self.defaultAssetCollection];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        self.didShowDefaultAssetCollection = YES;
    }
}

- (void)selectDefaultAssetCollection
{
    if (self.defaultAssetCollection && !self.didSelectDefaultAssetCollection)
    {
        NSIndexPath *indexPath = [self indexPathForAssetCollection:self.defaultAssetCollection];
        
        if (indexPath)
        {
            [UIView animateWithDuration:0.0f
                             animations:^{
                                 [self.tableView selectRowAtIndexPath:indexPath
                                                             animated:YES
                                                       scrollPosition:UITableViewScrollPositionTop];
                         }
                         completion:^(BOOL finished){
                             // mimic clearsSelectionOnViewWillAppear
                             if (finished)
                                 [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                         }];
        }
        
        self.didSelectDefaultAssetCollection = YES;
    }
}


#pragma mark - Grid view controller delegate

- (void)assetsGridViewController:(KITAssetsGridViewController *)picker photoLibraryDidChangeForAssetCollection:(id<KITAssetCollectionDataSource>)assetCollection
{
    NSIndexPath *indexPath = [self indexPathForAssetCollection:assetCollection];
    
    if (indexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end