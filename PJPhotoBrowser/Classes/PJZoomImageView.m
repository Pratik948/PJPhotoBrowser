//
//  PJZoomImageView.m
//  DACircularProgress
//
//  Created by Pratik on 06/11/17.
//

#import "PJZoomImageView.h"

typedef enum : NSUInteger {
    ZoomModeFill = 1,
    ZoomModeFit
} ZoomMode;

@interface PJZoomImageView () <UIScrollViewDelegate>
@property (nonatomic) CGSize oldSize;
@property (nonatomic) ZoomMode zoomMode;
@end

@implementation PJZoomImageView

- (void)setZoomMode:(ZoomMode)zoomMode {
    _zoomMode=zoomMode;
    [self updateImageView];
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (instancetype)initWithImage:(UIImage*)image {
    self = [super initWithFrame:CGRectZero];
    self.imageView.image=image;
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void)scrollToCenter {
    CGFloat x = (self.contentSize.width/2) - (self.bounds.size.width/2);
    CGFloat y = (self.contentSize.height/2) - (self.bounds.size.height/2);
    self.contentOffset = CGPointMake(x, y);
}

- (void)setup {
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.zoomMode = ZoomModeFit;
    
    self.backgroundColor=[UIColor clearColor];
    self.delegate=self;
    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:self.imageView];

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.imageView.image != nil &&  !CGSizeEqualToSize(self.oldSize, self.bounds.size)) {
        [self updateImageView];
        self.oldSize=self.bounds.size;
    }

    if (self.imageView.frame.size.width <= self.bounds.size.width) {
        CGPoint center = self.imageView.center;
        center.x = self.bounds.size.width * 0.5;
        self.imageView.center = center;
    }
    
    if (self.imageView.frame.size.height <= self.bounds.size.height) {
        CGPoint center = self.imageView.center;
        center.y = self.bounds.size.height * 0.5;
        self.imageView.center = center;
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    [self updateImageView];
}

- (void)handleDoubleTap {
    if (self.zoomScale==1) {
        [self setZoomScale:MAX(2, self.maximumZoomScale/3) animated:YES];
    }
    else {
        [self setZoomScale:1 animated:YES];
    }
}

#pragma mark - Lazy loading

- (UIImage *)image {
    return self.imageView.image;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    UIImage *oldImage = self.imageView.image;
    self.imageView.image=image;
    if (!CGSizeEqualToSize(oldImage.size, image.size)) {
        [self updateImageView];
    }
}

#pragma mark - updateImageView
- (void)updateImageView {
    UIImage *image = self.imageView.image;
    if (image==nil) {
        return;
    }
    CGSize size;
    
    switch (self.zoomMode) {
        case ZoomModeFit:
            size = [self fitSizeAspectRatio:image.size boundingSize:self.bounds.size];
            break;
        case ZoomModeFill:
            size = [self fillSizeAspectRatio:image.size minimumSize:self.bounds.size];
            break;
        default:
            break;
    }
    size.height = round(size.height);
    size.width = round(size.width);
    
    self.zoomScale = 1;
    self.maximumZoomScale = self.image.size.width / size.width;
    self.imageView.bounds = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, size.width, size.height);
    self.contentSize = size;
    self.imageView.center =  [self contentCenterForBoundingSize:self.bounds.size contentSize:self.contentSize];
    
}

- (CGSize)fitSizeAspectRatio:(CGSize)aspectRatio boundingSize:(CGSize)boundingSize {
    
    CGFloat widthRatio = (boundingSize.width / aspectRatio.width);
    CGFloat heightRatio = (boundingSize.height / aspectRatio.height);
    
    if (widthRatio < heightRatio) {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    }
    else if (heightRatio < widthRatio) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    }

    return CGSizeMake(ceil(boundingSize.width), ceil(boundingSize.height));
}

- (CGSize)fillSizeAspectRatio:(CGSize)aspectRatio minimumSize:(CGSize)minimumSize {
    CGFloat widthRatio = (minimumSize.width / aspectRatio.width);
    CGFloat heightRatio = (minimumSize.height / aspectRatio.height);
    
    if (widthRatio > heightRatio) {
        minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
    }
    else if (heightRatio > widthRatio) {
        minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
    }
    return CGSizeMake(ceil(minimumSize.width), ceil(minimumSize.height));
    
}

#pragma mark -

- (CGSize)intrinsicContentSize {
    return self.imageView.intrinsicContentSize;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self contentCenterForBoundingSize:self.bounds.size contentSize:self.contentSize];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (CGPoint)contentCenterForBoundingSize:(CGSize)boundingSize contentSize:(CGSize)contentSize {

    /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
    /// of content view changes too. But the default Apple implementation is keeping the last center
    /// value which doesn't make much sense. If the image ratio is not matching the screen
    /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
    /// so that we can get the correct new center value. When these are added, edges of contentView
    /// are aligned in realtime and always aligned with corners of scrollview.

    CGFloat horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5) : 0.0;
    CGFloat verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5) : 0.0;
    
    return CGPointMake(contentSize.width * 0.5 + horizontalOffest, contentSize.height * 0.5 + verticalOffset);
}

@end
