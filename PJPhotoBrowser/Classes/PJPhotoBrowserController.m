//
//  PJPhotoBrowserController.m
//  PJPhotoBrowser
//
//  Created by Pratik on 17/10/17.
//

#import "PJPhotoBrowserController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DACircularProgress/DACircularProgressView.h>
#import "PJZoomImageView.h"

@protocol PJPhotoContainerCollectionViewCellSingleTouchDelegate;

@interface PJPhotoContainerCollectionViewCell: UICollectionViewCell
@property (nonatomic) PJZoomImageView *zoomImageView;
@property (nonatomic) UIView *captionView;
@property (nonatomic, setter=setIsVideo:) BOOL isVideo;
- (void)addCaptionView:(UIView*)view;
- (void)setImageWithURL:(NSURL*)url;
@property (nonatomic) id <PJPhotoContainerCollectionViewCellSingleTouchDelegate> delegate;
@end

@protocol PJPhotoContainerCollectionViewCellSingleTouchDelegate <NSObject>
- (void)didTapOnCell:(PJPhotoContainerCollectionViewCell*)cell;
- (void)didTapPlayButton:(PJPhotoContainerCollectionViewCell*)cell;
@end

@interface PJPhotoContainerCollectionViewCell ()
@property (nonatomic) CGFloat progress;
@property (nonatomic) DACircularProgressView *progressView;
@property (nonatomic) UIButton *videoPlayButton;
@end

@implementation PJPhotoContainerCollectionViewCell

- (void)setIsVideo:(BOOL)isVideo {
    _isVideo=isVideo;
    if (isVideo) {
        if (!_videoPlayButton || _videoPlayButton.superview != self) {
            _videoPlayButton = [[UIButton alloc] init];
            UIImage *image = [UIImage imageNamed:@"playVideo" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            [_videoPlayButton setImage:image forState:UIControlStateNormal];
            _videoPlayButton.translatesAutoresizingMaskIntoConstraints=NO;
            [self addSubview:_videoPlayButton];
            [_videoPlayButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active=YES;
            [_videoPlayButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active=YES;
            [_videoPlayButton.widthAnchor constraintEqualToConstant:CGRectGetWidth([[UIScreen mainScreen] bounds])*0.2].active=YES;
            [_videoPlayButton.heightAnchor constraintEqualToAnchor:_videoPlayButton.widthAnchor].active=YES;
            [self bringSubviewToFront:_videoPlayButton];
            [_videoPlayButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        }
        _videoPlayButton.hidden=NO;
    }
    else {
        _videoPlayButton.hidden=YES;
    }
}

- (void)prepareForReuse {
    self.zoomImageView.imageView.image=nil;
    self.progressView.progress = 0;
    self.progress = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.captionView];
}

- (PJZoomImageView *)zoomImageView {
    if (!_zoomImageView) {
        _zoomImageView = [[PJZoomImageView alloc] initWithFrame:CGRectZero];
        _zoomImageView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:_zoomImageView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[zi]|" options:0 metrics:nil views:@{@"zi":_zoomImageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[zi]|" options:0 metrics:nil views:@{@"zi":_zoomImageView}]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        [_zoomImageView addGestureRecognizer:tapGesture];
    }
    return _zoomImageView;
}

- (DACircularProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
        _progressView.userInteractionEnabled = NO;
        _progressView.thicknessRatio = 0.1;
        _progressView.roundedCorners = NO;
        [self addSubview:_progressView];
        if (@available(iOS 9.0, *)) {
            _progressView.translatesAutoresizingMaskIntoConstraints=NO;
            [self addConstraints:@[
                                   [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                                   [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                   [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50],
                                   [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:50]
                                   ]];
        }
        else {
            _progressView.center = self.center;
        }
    }
    return _progressView;
}

- (void)setImageWithURL:(NSURL*)url {
    self.progressView.progress = MAX(MIN(1, self.progress), 0);
     SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             if (expectedSize > 0) {
                                 float progress = receivedSize / (float)expectedSize;
                                 self.progressView.progress = MAX(MIN(1, progress), 0);
                                 self.progress=progress;
                             }
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (!error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (image) {
                                        self.zoomImageView.imageView.image=image;
                                    }
                                });
                            }
                        }];
}

- (void)handleSingleTap {
    if ([self.delegate respondsToSelector:@selector(didTapOnCell:)]) {
        [self.delegate didTapOnCell:self];
    }
}

- (void)playVideo:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapPlayButton:)]) {
        [self.delegate didTapPlayButton:self];
    }
}

- (UIView*)captionView {
    if (!_captionView) {
        _captionView = [UIView new];
        _captionView.translatesAutoresizingMaskIntoConstraints=NO;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.translatesAutoresizingMaskIntoConstraints=NO;
        visualEffectView.tag=9911;
        [_captionView addSubview:visualEffectView];
        [_captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vev]|" options:0 metrics:nil views:@{@"vev":visualEffectView}]];
        [_captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vev]|" options:0 metrics:nil views:@{@"vev":visualEffectView}]];
        [self addSubview:_captionView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cv]|" options:0 metrics:nil views:@{@"cv":_captionView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cv]|" options:0 metrics:nil views:@{@"cv":_captionView}]];
    }
    return _captionView;
}

- (void)addCaptionView:(UIView*)view {
    for (UIView *subview in self.captionView.subviews) {
        if (subview.tag!=9911) {
            [subview removeFromSuperview];
        }
    }
    UIView *hairLine = [UIView new];
    hairLine.translatesAutoresizingMaskIntoConstraints=NO;
    [self.captionView addSubview:hairLine];
    hairLine.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.15];
    [self.captionView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints=NO;
    [self.captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hairLine(0.5)][view]|" options:0 metrics:nil views:@{@"hairLine":hairLine,@"view":view}]];
    [self.captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":view}]];
    [self.captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hairLine]|" options:0 metrics:nil views:@{@"hairLine":hairLine}]];
    [view sizeToFit];
}

@end

@interface PJPhotoBrowserController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PJPhotoContainerCollectionViewCellSingleTouchDelegate> {
    
    // Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
    NSArray *_fixedPhotosArray; // Provided via init

    // Paging
    NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    NSUInteger _pageIndexBeforeRotation;

    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
    // Navigation & controls
    NSTimer *_controlVisibilityTimer;
    UIBarButtonItem *_previousButton, *_nextButton, *_actionButton, *_doneButton;

    // Misc
    BOOL _hasBelongedToViewController;
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
    BOOL _displayActionButton;
    BOOL _leaveStatusBarAlone;
    BOOL _performingLayout;
    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _skipNextPagingScrollViewPositioning;
    BOOL _viewHasAppearedInitially;
    CGPoint _currentGridContentOffset;
}

@property (weak, nonatomic) UICollectionView* collectionView;
@property (nonatomic) NSUInteger currentIndex;
@end

@implementation PJPhotoBrowserController

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithDelegate:(id <PJPhotoBrowserDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
        [self _initialisation];
    }
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self init])) {
        _fixedPhotosArray = photosArray;
    }
    return self;
}

- (void)_initialisation {
    
    // Defaults
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
    self.hidesBottomBarWhenPushed = YES;
    _hasBelongedToViewController = NO;
    _photoCount = NSNotFound;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _displayActionButton = YES;
    _performingLayout = NO; // Reset on view did appear
    _rotating = NO;
    _viewIsActive = NO;
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
    _currentGridContentOffset = CGPointMake(0, CGFLOAT_MAX);
    _didSavePreviousStateOfNavBar = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
    else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // Super
    [super viewWillAppear:animated];
    // Status bar
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    if ([self.delegate respondsToSelector:@selector(rightBarButtonItemsForPhotoBrowser:)]) {
        NSMutableArray *arrButtons = [self.delegate rightBarButtonItemsForPhotoBrowser:self];
        [self.navigationItem setRightBarButtonItems:arrButtons animated:YES];
    }
    // Update UI
    [self hideControlsAfterDelay];
    // If rotation occured while we're presenting a modal
    // and the index changed, make sure we show the right one now
    if (_currentPageIndex != _pageIndexBeforeRotation) {
        [self jumpToPageAtIndex:_pageIndexBeforeRotation animated:NO];
    }
    // Layout
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNavBarAppearance:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Detect if rotation occurs while we're presenting a modal
    _pageIndexBeforeRotation = _currentPageIndex;
    // Check that we're disappearing for good
    // self.isMovingFromParentViewController just doesn't work, ever. Or self.isBeingDismissed
    if ((_doneButton && self.navigationController.isBeingDismissed) ||
        ([self.navigationController.viewControllers objectAtIndex:0] != self && ![self.navigationController.viewControllers containsObject:self])) {
        // State
        _viewIsActive = NO;
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
    }
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIApplication sharedApplication].statusBarStyle = _previousStatusBarStyle;
    }
    
    // Super
    [super viewWillDisappear:animated];
    
}

- (NSUInteger)currentIndex {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if (indexPaths.count>0) {
        _currentPageIndex = [(NSIndexPath*)indexPaths.firstObject item];
    }
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
    }
    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    // Update layout
    if ([self isViewLoaded]) {
        [self performLayout];
        [self.collectionView reloadData];
        [self.view setNeedsLayout];
    }
    
}

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    NSUInteger numberOfPhotos = [self numberOfPhotos];

    // Navigation buttons
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        // We're first on stack so show done button
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        // Set appearance
        [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];
        [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsCompact];
        [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
        [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        self.navigationItem.rightBarButtonItem = _doneButton;
    } else {
        // We're not first so show back button
        UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        NSString *backButtonTitle = previousViewController.navigationItem.backBarButtonItem ? previousViewController.navigationItem.backBarButtonItem.title : previousViewController.title;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        // Appearance
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsCompact];
        [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
        [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        _previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem; // remember previous
        previousViewController.navigationItem.backBarButtonItem = newBackButton;
    }
    
    // Toolbar items
    BOOL hasItems = NO;
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 32; // To balance action button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // Middle - Nav
    if (_previousButton && _nextButton && numberOfPhotos > 1) {
        hasItems = YES;
        [items addObject:flexSpace];
        [items addObject:_previousButton];
        [items addObject:flexSpace];
        [items addObject:_nextButton];
        [items addObject:flexSpace];
    } else {
        [items addObject:flexSpace];
    }
    // Right - Action
    if (_actionButton && !(!hasItems && !self.navigationItem.rightBarButtonItem)) {
        [items addObject:_actionButton];
    } else {
        // We're not showing the toolbar so try and show in top right
        if (_actionButton)
            self.navigationItem.rightBarButtonItem = _actionButton;
        [items addObject:fixedSpace];
    }
    _performingLayout = NO;
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
}

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
    // Change page
    if (index < [self numberOfPhotos]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        if ([_collectionView numberOfItemsInSection:0]>=indexPath.item) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateNavigation];
    });
    // Update timer to give more time
    [self hideControlsAfterDelay];
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_fixedPhotosArray) {
            _photoCount = _fixedPhotosArray.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (void)updateNavigation {
    
    // Title
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    if (numberOfPhotos > 1) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
            self.title = [_delegate photoBrowser:self titleForPhotoAtIndex:(self.currentIndex)];
        } else {
            self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(self.currentIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
        }
    } else {
        self.title = nil;
    }
}

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = nil;
    navBar.shadowImage = nil;
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    navBar.translucent=YES;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        navBar.barTintColor = _previousNavBarBarTintColor;
        navBar.barStyle = _previousNavBarStyle;
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsCompact];
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    if ([self.collectionView numberOfItemsInSection:0]>=index) {
        if (index==0) {
            _currentPageIndex=index;
        }
        else {
            _currentPageIndex=index;
        }
        [self jumpToPageAtIndex:_currentPageIndex animated:NO];
    }
}

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Force visible
    if (![self numberOfPhotos])
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
    // CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if (!_leaveStatusBarAlone) {
        
        // Hide status bar
        if (!_isVCBasedStatusBarAppearance) {
            
            // Non-view controller based
//            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
            [UIApplication sharedApplication].statusBarHidden=hidden;
        } else {
            
            // View controller based so animate away
            _statusBarShouldBeHidden = hidden;
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {}];
            
        }
        
    }

    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;
        
        // Nav bar slides up on it's own on iOS 7+
        [self.navigationController.navigationBar setAlpha:alpha];
        for (PJPhotoContainerCollectionViewCell *cell in self.collectionView.visibleCells) {
            [UIView animateWithDuration:animationDuration animations:^{
                CGFloat alpha = hidden ? 0 : 1;
                cell.captionView.alpha=alpha;
            }];
        }
    } completion:^(BOOL finished) {}];
    
    // Control hiding timer
    // Will cancel existing timer but only begin hiding if
    // they are visible
    if (!permanent) [self hideControlsAfterDelay];
    
}

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return [self presentingViewControllerPrefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)cancelControlHiding {
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
    if (![self areControlsHidden]) {
        [self cancelControlHiding];
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}

- (BOOL)areControlsHidden { return (self.navigationController.navigationBar.alpha==0); }
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)showControls { [self setControlsHidden:NO animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

#pragma mark - Misc

- (void)doneButtonPressed:(id)sender {
    // Only if we're modal and there's a done button
    if (_doneButton) {
        // Dismiss view controller
        if ([_delegate respondsToSelector:@selector(photoBrowserDidFinishModalPresentation:)]) {
            // Call delegate method and let them dismiss us
            [_delegate photoBrowserDidFinishModalPresentation:self];
        } else  {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


#pragma mark - UICollectionView

- (UICollectionView*)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView = collectionView;
        _collectionView.translatesAutoresizingMaskIntoConstraints=NO;
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.pagingEnabled=YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.showsVerticalScrollIndicator=NO;
        [self.view addSubview:_collectionView];
        [_collectionView registerClass:[PJPhotoContainerCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:@{@"cv":_collectionView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cv]|" options:0 metrics:nil views:@{@"cv":_collectionView}]];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfPhotos];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PJPhotoContainerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    PJPhoto *photo;
    if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
        photo = [_delegate photoBrowser:self photoAtIndex:indexPath.item];
    }
    else {
        photo = [_fixedPhotosArray objectAtIndex:indexPath.item];
    }
    [cell setImageWithURL:photo.photoURL];
    if ([_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
        UIView *view = [_delegate photoBrowser:self captionViewForPhotoAtIndex:indexPath.item];
        if (view) {
            [cell addCaptionView:view];
        }
        if ([self areControlsHidden]) {
            cell.captionView.alpha=0;
        }
        else {
            cell.captionView.alpha=1;
        }
    }
    cell.isVideo=photo.isVideo;
    cell.delegate=self;
    [cell insertSubview:cell.videoPlayButton aboveSubview:cell.zoomImageView];
    return cell;
}

#pragma mark - PJPhotoContainerCollectionViewCellSingleTouchDelegate

- (void)didTapOnCell:(PJPhotoContainerCollectionViewCell *)cell {
    if ([self areControlsHidden]) {
        [self showControls];
    }
    else {
        [self hideControls];
    }
}

- (void)didTapPlayButton:(PJPhotoContainerCollectionViewCell *)cell {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didTapPlayButtonAtPhotoIndex:)]) {
        [self.delegate photoBrowser:self didTapPlayButtonAtPhotoIndex:self.currentIndex];
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateNavigation];
}

@end
