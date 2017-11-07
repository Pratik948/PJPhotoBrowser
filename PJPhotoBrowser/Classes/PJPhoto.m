//
//  PJPhoto.m
//  PJPhotoBrowser
//
//  Created by Pratik on 17/10/17.
//

#import "PJPhoto.h"

@interface PJPhoto()
@end

@implementation PJPhoto

#pragma mark - Class Methods

+ (PJPhoto *)photoWithImage:(UIImage *)image {
    return [[PJPhoto alloc] initWithImage:image];
}

+ (PJPhoto *)photoWithURL:(NSURL *)url {
    return [[PJPhoto alloc] initWithURL:url];
}

+ (PJPhoto *)videoWithURL:(NSURL *)url {
    return [[PJPhoto alloc] initWithVideoURL:url];
}

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        self.emptyImage = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = url;
    }
    return self;
}

- (id)initWithVideoURL:(NSURL *)url {
    if ((self = [super init])) {
        self.videoURL = url;
        self.isVideo = YES;
        self.emptyImage = YES;
    }
    return self;
}

@end
