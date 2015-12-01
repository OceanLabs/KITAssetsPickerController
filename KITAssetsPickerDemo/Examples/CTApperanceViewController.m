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

#import "CTApperanceViewController.h"

// import headers that need to be customised
#import <KITAssetsPickerController/KITAssetCollectionViewCell.h>
#import <KITAssetsPickerController/KITAssetsGridView.h>
#import <KITAssetsPickerController/KITAssetsGridViewFooter.h>
#import <KITAssetsPickerController/KITAssetsGridViewCell.h>
#import <KITAssetsPickerController/KITAssetsGridSelectedView.h>
#import <KITAssetsPickerController/KITAssetCheckmark.h>
#import <KITAssetsPickerController/KITAssetsPageView.h>



@interface CTApperanceViewController ()

@property (nonatomic, strong) UIColor *color1;
@property (nonatomic, strong) UIColor *color2;
@property (nonatomic, strong) UIColor *color3;
@property (nonatomic, strong) UIFont *font;

@end



@implementation CTApperanceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set appearance
    // for demo purpose. you might put the code in app delegate's application:didFinishLaunchingWithOptions: method
    self.color1 = [UIColor colorWithRed:102.0/255.0 green:161.0/255.0 blue:130.0/255.0 alpha:1];
    self.color2 = [UIColor colorWithRed:60.0/255.0 green:71.0/255.0 blue:75.0/255.0 alpha:1];
    self.color3 = [UIColor colorWithWhite:0.9 alpha:1];
    self.font   = [UIFont fontWithName:@"Futura-Medium" size:22.0];

    // Navigation Bar apperance
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    
    // set nav bar style to black to force light content status bar style
    navBar.barStyle = UIBarStyleBlack;
    
    // bar tint color
    navBar.barTintColor = self.color1;
    
    // tint color
    navBar.tintColor = self.color2;
    
    // title
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName: self.color2,
      NSFontAttributeName : self.font};
    
    // bar button item appearance
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName : [self.font fontWithSize:18.0]}
                                 forState:UIControlStateNormal];
    
    // albums view
    UITableView *assetCollectionView = [UITableView appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    assetCollectionView.backgroundColor = self.color2;
    
    // asset collection appearance
    KITAssetCollectionViewCell *assetCollectionViewCell = [KITAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = [self.font fontWithSize:16.0];
    assetCollectionViewCell.titleTextColor = self.color1;
    assetCollectionViewCell.selectedTitleTextColor = self.color2;
    assetCollectionViewCell.countFont = [self.font fontWithSize:12.0];
    assetCollectionViewCell.countTextColor = self.color1;
    assetCollectionViewCell.selectedCountTextColor = self.color2;
    assetCollectionViewCell.accessoryColor = self.color1;
    assetCollectionViewCell.selectedAccessoryColor = self.color2;
    assetCollectionViewCell.backgroundColor = self.color3;
    assetCollectionViewCell.selectedBackgroundColor = [self.color1 colorWithAlphaComponent:0.4];

    // grid view
    KITAssetsGridView *assetsGridView = [KITAssetsGridView appearance];
    assetsGridView.gridBackgroundColor = self.color3;
    
    // assets grid footer apperance
    KITAssetsGridViewFooter *assetsGridViewFooter = [KITAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = [self.font fontWithSize:16.0];
    assetsGridViewFooter.textColor = self.color2;
    
    // grid view cell
    KITAssetsGridViewCell *assetsGridViewCell = [KITAssetsGridViewCell appearance];
    assetsGridViewCell.highlightedColor = [UIColor colorWithWhite:1 alpha:0.3];
    
    // selected grid view
    KITAssetsGridSelectedView *assetsGridSelectedView = [KITAssetsGridSelectedView appearance];
    assetsGridSelectedView.selectedBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    assetsGridSelectedView.tintColor = self.color1;
    assetsGridSelectedView.font = [self.font fontWithSize:18.0];
    assetsGridSelectedView.textColor = self.color2;
    assetsGridSelectedView.borderWidth = 1.0;
        
    // check mark
    [KITAssetCheckmark appearance].tintColor = self.color1;
    
    // page view (preview)
    KITAssetsPageView *assetsPageView = [KITAssetsPageView appearance];
    assetsPageView.pageBackgroundColor = self.color3;
    assetsPageView.fullscreenBackgroundColor = self.color2;
    
    // progress view
    [UIProgressView appearanceWhenContainedIn:[KITAssetsPickerController class], nil].tintColor = self.color1;
    
}

- (void)dealloc
{
    // reset appearance
    // for demo purpose. it is not necessary to reset appearance in real case.
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    
    navBar.barStyle = UIBarStyleDefault;
    
    navBar.barTintColor = nil;
    
    navBar.tintColor = nil;
    
    navBar.titleTextAttributes = nil;
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:nil
                                      forState:UIControlStateNormal];
    
    UITableView *assetCollectionView = [UITableView appearanceWhenContainedIn:[KITAssetsPickerController class], nil];
    assetCollectionView.backgroundColor = [UIColor whiteColor];
    
    KITAssetCollectionViewCell *assetCollectionViewCell = [KITAssetCollectionViewCell appearance];
    assetCollectionViewCell.titleFont = nil;
    assetCollectionViewCell.titleTextColor = nil;
    assetCollectionViewCell.selectedTitleTextColor = nil;
    assetCollectionViewCell.countFont = nil;
    assetCollectionViewCell.countTextColor = nil;
    assetCollectionViewCell.selectedCountTextColor = nil;
    assetCollectionViewCell.accessoryColor = nil;
    assetCollectionViewCell.selectedAccessoryColor = nil;
    assetCollectionViewCell.backgroundColor = nil;
    assetCollectionViewCell.selectedBackgroundColor = nil;
    
    KITAssetsGridView *assetsGridView = [KITAssetsGridView appearance];
    assetsGridView.gridBackgroundColor = nil;
    
    KITAssetsGridViewFooter *assetsGridViewFooter = [KITAssetsGridViewFooter appearance];
    assetsGridViewFooter.font = nil;
    assetsGridViewFooter.textColor = nil;
    
    KITAssetsGridViewCell *assetsGridViewCell = [KITAssetsGridViewCell appearance];
    assetsGridViewCell.highlightedColor = nil;
    
    KITAssetsGridSelectedView *assetsGridSelectedView = [KITAssetsGridSelectedView appearance];
    assetsGridSelectedView.selectedBackgroundColor = nil;
    assetsGridSelectedView.tintColor = nil;
    assetsGridSelectedView.font = nil;
    assetsGridSelectedView.textColor = nil;
    assetsGridSelectedView.borderWidth = 0.0;
    
    [KITAssetCheckmark appearance].tintColor = nil;
    
    KITAssetsPageView *assetsPageView = [KITAssetsPageView appearance];
    assetsPageView.pageBackgroundColor = nil;
    assetsPageView.fullscreenBackgroundColor = nil;
    
    [UIProgressView appearanceWhenContainedIn:[KITAssetsPickerController class], nil].tintColor = nil;
}


- (void)pickAssets:(id)sender
{
            // init picker
            KITAssetsPickerController *picker = [[KITAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // to show selection order
            picker.showsSelectionIndex = YES;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
            
}


@end
