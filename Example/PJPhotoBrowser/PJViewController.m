//
//  PJViewController.m
//  PJPhotoBrowser
//
//  Created by Pratik948 on 10/23/2017.
//  Copyright (c) 2017 Pratik948. All rights reserved.
//

#import "PJViewController.h"
#import <PJPhotoBrowser/PJPhotoBrowserController.h>
#import <SDWebImage/SDWebImageManager.h>

@interface PJViewController () <PJPhotoBrowserDelegate, UITableViewDelegate, UITableViewDataSource>
@property NSMutableArray *imageArray;
@end

@implementation PJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *clearCache = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCache:)];
    [self.navigationItem setRightBarButtonItem:clearCache animated:YES];
    self.imageArray = [NSMutableArray array];
    for (int i =1 ; i<=10; i++) {
        [self.imageArray addObject:[NSString stringWithFormat:@"http://lorempixel.com/output/abstract-q-c-640-480-%d.jpg", i]];
        [self.imageArray addObject:[NSString stringWithFormat:@"http://lorempixel.com/output/city-q-c-640-480-%d.jpg", i]];
        [self.imageArray addObject:[NSString stringWithFormat:@"http://lorempixel.com/output/nightlife-q-c-640-480-%d.jpg", i]];
    }
}

- (void)clearCache:(id)sender {
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
}

- (IBAction)openBrowser:(id)sender {
    PJPhotoBrowserController *browser = [[PJPhotoBrowserController alloc] initWithDelegate:self];
    [self showViewController:browser sender:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [browser setCurrentPhotoIndex:2];
    });
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(PJPhotoBrowserController *)photoBrowser {
    return self.imageArray.count;
}

- (PJPhoto*)photoBrowser:(PJPhotoBrowserController *)photoBrowser photoAtIndex:(NSUInteger)index {
    PJPhoto *photo = [PJPhoto photoWithURL:[NSURL URLWithString:[self.imageArray objectAtIndex:index]]];
    return photo;
}

- (UIView *)photoBrowser:(PJPhotoBrowserController *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    UILabel *captionView = [UILabel new];
    captionView.text=@"Dummy Text\nDummy Text";
    captionView.textAlignment=NSTextAlignmentCenter;
    captionView.numberOfLines=0;
    captionView.textColor=[UIColor whiteColor];
    captionView.translatesAutoresizingMaskIntoConstraints=NO;
    return captionView;
}

- (NSMutableArray *)rightBarButtonItemsForPhotoBrowser:(PJPhotoBrowserController *)photoBrowser {
    NSMutableArray *arrRightButtons = [NSMutableArray array];
    UIBarButtonItem *optionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    [arrRightButtons addObject:optionButton];
    return arrRightButtons;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Image: %ld", indexPath.row+1];
    cell.detailTextLabel.text = [_imageArray objectAtIndex:indexPath.item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PJPhotoBrowserController *browser = [[PJPhotoBrowserController alloc] initWithDelegate:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [browser setCurrentPhotoIndex:indexPath.row];
    });
    [self showViewController:browser sender:self];
}

@end

