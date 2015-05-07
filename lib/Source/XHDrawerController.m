//
//  XHDrawerController.m
//  XHDrawerController
//
//  Created by 曾 宪华 on 13-12-27.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHDrawerController.h"
#import "XHZoomDrawerView.h"
#import "XHDrawerControllerHeader.h"

#import <objc/runtime.h>

static const CGFloat XHAnimateDuration = 1.5f;
static const CGFloat XHAnimationDampingDuration = 1.5f;
static const CGFloat XHAnimationVelocity = 20.f;


const char *XHDrawerControllerKey = "XHDrawerControllerKey";

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@implementation UIViewController (XHDrawerController)

- (XHDrawerController *)drawerController {
    XHDrawerController *panDrawerController = objc_getAssociatedObject(self, &XHDrawerControllerKey);
    if (!panDrawerController) {
        panDrawerController = self.parentViewController.drawerController;
    }
    
    return panDrawerController;
}


- (void)setDrawerController:(XHDrawerController *)drawerController {
    objc_setAssociatedObject(self, &XHDrawerControllerKey, drawerController, OBJC_ASSOCIATION_ASSIGN);
}

@end


@interface XHDrawerController () <UIScrollViewDelegate>
@property (nonatomic, assign, readwrite) XHDrawerSide openSide;

@property (nonatomic, strong) XHZoomDrawerView *zoomDrawerView;

@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger cuurrentContentOffsetX;
@end

@implementation XHDrawerController

#pragma mark - UIViewController Overrides

- (void)_setup {
    self.animateDuration = XHAnimateDuration;
    self.animationDampingDuration = XHAnimationDampingDuration;
    self.animationVelocity = XHAnimationVelocity;
    self.openSide = XHDrawerSideNone;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)loadView {
    _zoomDrawerView = [[XHZoomDrawerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.zoomDrawerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.zoomDrawerView.autoresizesSubviews = YES;
    self.view = self.zoomDrawerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = NO;
    self.zoomDrawerView.scrollView.delegate = self;
    self.zoomDrawerView.contentContainerButton.userInteractionEnabled = NO;
    [self.zoomDrawerView.contentContainerButton addTarget:self action:@selector(contentContainerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Open/Close methods

- (void)toggleDrawerSide:(XHDrawerSide)drawerSide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    //断定是不是为空
    NSParameterAssert(drawerSide != XHDrawerSideNone);
    if(self.openSide == XHDrawerSideNone){
        //打开策划的栏。
        [self openDrawerSide:drawerSide animated:animated completion:completion];
    } else {
        if((drawerSide == XHDrawerSideLeft &&
            self.openSide == XHDrawerSideLeft) ||
           (drawerSide == XHDrawerSideRight &&
            self.openSide == XHDrawerSideRight)){
               [self closeDrawerAnimated:animated completion:completion];
           }
        else if(completion) {
            completion(NO);
        }
    }
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    [self closeDrawerAnimated:animated velocity:self.animationVelocity animationOptions:UIViewAnimationOptionCurveEaseInOut completion:completion];
}

- (void)closeDrawerAnimated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion {
    
    CGFloat damping = [self isSpringAnimationOn]&& animated ? 0.7f : 1.0f;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [self.scrollView setContentOffset:CGPointMake(XHContentContainerViewOriginX, 0.0f) animated:NO];
        } completion:^(BOOL finished) {
            self.openSide = XHDrawerSideNone;
            self.zoomDrawerView.contentContainerButton.userInteractionEnabled = NO;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:options animations:^{
            [self.scrollView setContentOffset:CGPointMake(XHContentContainerViewOriginX, 0.0f) animated:NO];
        } completion:^(BOOL finished) {
            self.openSide = XHDrawerSideNone;
            self.zoomDrawerView.contentContainerButton.userInteractionEnabled = NO;
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)openDrawerSide:(XHDrawerSide)drawerSide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    NSParameterAssert(drawerSide != XHDrawerSideNone);
    
    [self openDrawerSide:drawerSide animated:animated velocity:self.animationVelocity animationOptions:UIViewAnimationOptionCurveEaseInOut completion:completion];
}
//动画效果
- (void)openDrawerSide:(XHDrawerSide)drawerSide animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion {
    NSParameterAssert(drawerSide != XHDrawerSideNone);
//    显示打开侧栏的
    self.openSide = drawerSide;
    //damp阻尼系数
    CGFloat damping = [self isSpringAnimationOn] ? 0.7f : 1.0f;
    //damping是这个动画的反弹的效果；velocity是这个动画的初始速度。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //整个animation中是需要进行的动画。
            if (drawerSide == XHDrawerSideLeft) {
                //设置了滚动视图的显示范围吧。
                [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
                //滚动视图向某个方向滚动，之后进行scrollview的代理调用
            } else if (drawerSide == XHDrawerSideRight) {
                [self.scrollView setContentOffset:CGPointMake(2 * XHContentContainerViewOriginX, 0.0f) animated:NO];
            }
        } completion:^(BOOL finished) {
            self.openSide = drawerSide;
            self.zoomDrawerView.contentContainerButton.userInteractionEnabled = YES;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:options animations:^{
            if (drawerSide == XHDrawerSideLeft) {
                [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
            } else if (drawerSide == XHDrawerSideRight) {
                [self.scrollView setContentOffset:CGPointMake(2 * XHContentContainerViewOriginX, 0.0f) animated:NO];
            }
            
        } completion:^(BOOL finished) {
            self.openSide = drawerSide;
            self.zoomDrawerView.contentContainerButton.userInteractionEnabled = YES;
            if (completion) {
                completion(finished);
            }
        }];
    }
}
//获取器
#pragma mark - Accessors

- (void)setBackgroundView:(UIView *)backgroundView {
    self.zoomDrawerView.backgroundView = backgroundView;
}

- (UIView *)backgroundView {
    return self.zoomDrawerView.backgroundView;
}

- (UIScrollView *)scrollView {
    return self.zoomDrawerView.scrollView;
}
//这个是给滚动视图里面添加视图
- (void)setCenterViewController:(UIViewController *)centerViewController {
    if (![self isViewLoaded]) {
        [self view];
    }
    UIViewController *currentContentViewController =self.centerViewController;
    _centerViewController = centerViewController;
    
    UIView *contentContainerView = self.zoomDrawerView.contentContainerView;
    CGAffineTransform currentTransform = [contentContainerView transform];
    [contentContainerView setTransform:CGAffineTransformIdentity];
    
    [self replaceController:currentContentViewController
              newController:self.centerViewController
                  container:self.zoomDrawerView.contentContainerView];
    
    [contentContainerView setTransform:currentTransform];
    [self.zoomDrawerView setNeedsLayout];
}
/**
 *  添加左侧的视图
 *
 *  @param leftViewController <#leftViewController description#>
 */
- (void)setLeftViewController:(UIViewController *)leftViewController {
    if (![self isViewLoaded]) {
        [self view];
    }
    UIViewController *currentLeftViewController = self.leftViewController;
    _leftViewController = leftViewController;
    [self replaceController:currentLeftViewController
              newController:self.leftViewController
                  container:self.zoomDrawerView.leftContainerView];
}
/**
 *  添加右侧的视图，
 *
 *  @param rightViewController <#rightViewController description#>
 */
- (void)setRightViewController:(UIViewController *)rightViewController {
    if (![self isViewLoaded]) {
        [self view];
    }
    UIViewController *currentLeftViewController = self.rightViewController;
    _rightViewController = rightViewController;
    [self replaceController:currentLeftViewController
              newController:self.rightViewController
                  container:self.zoomDrawerView.rightContainerView];
}


#pragma mark - Instance Methods
/**
 *  打开左侧视图后，点击这个缩略图，返回主界面。
 *
 *  @param sender button
 */
- (void)contentContainerButtonPressed:(id)sender {
    [self closeDrawerAnimated:YES completion:NULL];
}
/**
 *  这个应该是在我们的左右的视图之间进行相应的切换的一个函数，
 *
 *  @param oldController 旧的控制器
 *  @param newController 转化到新的控制器
 *  @param container     展示的容器。
 */
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController container:(UIView *)container
{
    if (newController) {
        [self addChildViewController:newController];
        [[newController view] setFrame:[container bounds]];
        [newController setDrawerController:self];
        
        if (oldController) {
            [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:0 animations:nil completion:^(BOOL finished) {
                
                [newController didMoveToParentViewController:self];
                
                [oldController willMoveToParentViewController:nil];
                [oldController removeFromParentViewController];
                [oldController setDrawerController:nil];
                
            }];
        } else {
            [container addSubview:[newController view]];
            [newController didMoveToParentViewController:self];
        }
    } else {
        [[oldController view] removeFromSuperview];
        [oldController willMoveToParentViewController:nil];
        [oldController removeFromParentViewController];
        [oldController setDrawerController:nil];
    }
}
/**
 *  这个应该是根据是不是做滑动的时候，禁止掉button的功能。
 */
- (void)updateContentContainerButton {
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat contentOffsetX = contentOffset.x;
    //这里面是根据content的文本的起点进行判断
    if (contentOffsetX < XHContentContainerViewOriginX) {
        self.zoomDrawerView.contentContainerButton.userInteractionEnabled = YES;
    } else if (contentOffsetX > XHContentContainerViewOriginX) {
        self.zoomDrawerView.contentContainerButton.userInteractionEnabled = YES;
    } else {
        self.zoomDrawerView.contentContainerButton.userInteractionEnabled = NO;
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //获取当前的文本的offset位置。
    self.cuurrentContentOffsetX = scrollView.contentOffset.x;
}
//这个是滚动完成之后，做些处理。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //获取当前的contentoffset
    CGPoint contentOffset = [scrollView contentOffset];
    
    CGFloat currentContentOffsetX = contentOffset.x;
    if (currentContentOffsetX > 0 && currentContentOffsetX < XHContentContainerViewOriginX && self.cuurrentContentOffsetX > currentContentOffsetX) {
        self.openSide = XHDrawerSideLeft;
    } else if (currentContentOffsetX > XHContentContainerViewOriginX && currentContentOffsetX < (XHContentContainerViewOriginX * 2) && self.cuurrentContentOffsetX < currentContentOffsetX) {
        self.openSide = XHDrawerSideRight;
    }
    
    CGFloat contentOffsetX = 0.0;
    if (self.openSide == XHDrawerSideRight) {
        contentOffsetX = XHContentContainerViewOriginX * 2 - contentOffset.x;
    } else if (self.openSide == XHDrawerSideLeft) {
        contentOffsetX = contentOffset.x;
    }
    
    //创建缩略比例吧
    CGFloat contentContainerScale = powf((contentOffsetX + XHContentContainerViewOriginX) / (XHContentContainerViewOriginX * 2.0f), .5f);
    if (isnan(contentContainerScale)) {
        contentContainerScale = 0.0f;
    }

    CGAffineTransform contentContainerViewTransform = CGAffineTransformMakeScale(contentContainerScale, contentContainerScale);
    CGAffineTransform leftContainerViewTransform = CGAffineTransformMakeTranslation(contentOffsetX / 1.5f, 0.0f);
    CGAffineTransform rightContainerViewTransform = CGAffineTransformMakeTranslation(contentOffsetX / -1.5f, 0.0f);
    
    self.zoomDrawerView.contentContainerView.transform = contentContainerViewTransform;
    
    self.zoomDrawerView.leftContainerView.transform = leftContainerViewTransform;
    self.zoomDrawerView.leftContainerView.alpha = 1 - contentOffsetX / XHContentContainerViewOriginX;
    
    self.zoomDrawerView.rightContainerView.transform = rightContainerViewTransform;
    self.zoomDrawerView.rightContainerView.alpha = 1 - contentOffsetX / XHContentContainerViewOriginX;
    
    if (self.openSide == XHDrawerSideLeft) {
        static BOOL leftContentViewControllerVisible = NO;
        if (contentOffsetX >= XHContentContainerViewOriginX) {
            if (leftContentViewControllerVisible) {
                [self.leftViewController beginAppearanceTransition:NO animated:YES];
                [self.leftViewController endAppearanceTransition];
                leftContentViewControllerVisible = NO;
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
                    [self setNeedsStatusBarAppearanceUpdate];
            }
        } else if (contentOffsetX < XHContentContainerViewOriginX && !leftContentViewControllerVisible) {
            [self.leftViewController beginAppearanceTransition:YES animated:YES];
            leftContentViewControllerVisible = YES;
            [self.leftViewController endAppearanceTransition];
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
                [self setNeedsStatusBarAppearanceUpdate];
        }
    } else if (self.openSide == XHDrawerSideRight) {
        static BOOL rightContentViewControllerVisible = NO;
        if (contentOffsetX >= XHContentContainerViewOriginX) {
            if (rightContentViewControllerVisible) {
                [self.rightViewController beginAppearanceTransition:NO animated:YES];
                [self.rightViewController endAppearanceTransition];
                rightContentViewControllerVisible = NO;
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
                    [self setNeedsStatusBarAppearanceUpdate];
            }
        } else if (contentOffsetX < XHContentContainerViewOriginX && !rightContentViewControllerVisible) {
            [self.rightViewController beginAppearanceTransition:YES animated:YES];
            rightContentViewControllerVisible = YES;
            [self.rightViewController endAppearanceTransition];
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
                [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateContentContainerButton];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateContentContainerButton];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGFloat targetContentOffsetX = targetContentOffset->x;
    CGFloat drawerPadding = XHContentContainerViewOriginX * 2 / 3.;
    if ((targetContentOffsetX >= drawerPadding && targetContentOffsetX < XHContentContainerViewOriginX && self.openSide == XHDrawerSideLeft) || (targetContentOffsetX > XHContentContainerViewOriginX && targetContentOffsetX <= (XHContentContainerViewOriginX * 2 - drawerPadding) && self.openSide == XHDrawerSideRight)) {
        targetContentOffset->x = XHContentContainerViewOriginX;
    } else if ((targetContentOffsetX >= 0 && targetContentOffsetX <= drawerPadding && self.openSide == XHDrawerSideLeft)) {
        targetContentOffset->x = 0.0f;
        self.openSide = XHDrawerSideLeft;
    } else if ((targetContentOffsetX > (XHContentContainerViewOriginX * 2 - drawerPadding) && targetContentOffsetX <= (XHContentContainerViewOriginX * 2) && self.openSide == XHDrawerSideRight)) {
        targetContentOffset->x = XHContentContainerViewOriginX * 2;
        self.openSide = XHDrawerSideRight;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *viewController;
    if (self.scrollView.contentOffset.x < XHContentContainerViewOriginX) {
        viewController = self.leftViewController;
    } else if (self.scrollView.contentOffset.x > XHContentContainerViewOriginX) {
        viewController = self.rightViewController;
    } else {
        viewController = self.centerViewController;
    }
    return viewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UIViewController *viewController;
    if (self.scrollView.contentOffset.x < XHContentContainerViewOriginX) {
        viewController = self.leftViewController;
    } else if (self.scrollView.contentOffset.x > XHContentContainerViewOriginX) {
        viewController = self.rightViewController;
    } else {
        viewController = self.centerViewController;
    }
    return viewController;
}

@end
