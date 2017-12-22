//
//  PJPhotoBrowserController.h
//  PJPhotoBrowser
//
//  Created by Pratik on 17/10/17.
//

#import <UIKit/UIKit.h>
#import "PJPhoto.h"

@protocol PJPhotoBrowserDelegate;
@interface PJPhotoBrowserController : UIViewController

@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, strong) IBOutlet id<PJPhotoBrowserDelegate> delegate;
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <PJPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

@end

@protocol PJPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(PJPhotoBrowserController *)photoBrowser;
- (PJPhoto*)photoBrowser:(PJPhotoBrowserController *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (UIView *)photoBrowser:(PJPhotoBrowserController *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(PJPhotoBrowserController *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowserDidFinishModalPresentation:(PJPhotoBrowserController *)photoBrowser;
- (void)photoBrowser:(PJPhotoBrowserController *)photoBrowser didTapPlayButtonAtPhotoIndex:(NSUInteger)photoIndex;
- (NSMutableArray*)rightBarButtonItemsForPhotoBrowser:(PJPhotoBrowserController *)photoBrowser;

@end

