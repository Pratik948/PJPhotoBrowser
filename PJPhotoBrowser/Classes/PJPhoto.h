//
//  PJPhoto.h
//  PJPhotoBrowser
//
//  Created by Pratik on 17/10/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PJPhoto : NSObject

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;

+ (PJPhoto *)photoWithImage:(UIImage *)image;
+ (PJPhoto *)photoWithURL:(NSURL *)url;
+ (PJPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithVideoURL:(NSURL *)url;

@end


