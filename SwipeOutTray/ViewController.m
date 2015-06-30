//
//  ViewController.m
//  SwipeOutTray
//
//  Created by Brexton Pham on 6/30/15.
//  Copyright (c) 2015 Brexton Pham. All rights reserved.
//

#define GUTTER_WIDTH 100

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIVisualEffectView *trayView;
@property (nonatomic, strong) NSLayoutConstraint *trayLeftEdgeConstraint;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, assign) BOOL gravityIsLeft;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehavior;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yik yak image.jpg"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    
    [self setupTrayView];
    [self setupGestureRecognizers];
    
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    [self setupBehaviors];
}

-(void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentPoint = [recognizer locationInView:self.view];
    CGPoint xOnlyLocation = CGPointMake(currentPoint.x, self.view.center.y); //ignore any gestures in y direction
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.panAttachmentBehavior = [[UIAttachmentBehavior alloc]initWithItem:self.trayView attachedToAnchor:xOnlyLocation];
        [self.animator addBehavior:self.panAttachmentBehavior];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        self.panAttachmentBehavior.anchorPoint = xOnlyLocation; //update point property
    }
    else if ((recognizer.state == UIGestureRecognizerStateEnded) ||
             (recognizer.state == UIGestureRecognizerStateCancelled))
    {
        [self.animator removeBehavior:self.panAttachmentBehavior]; //remove attachment behavior
        CGPoint velocity = [recognizer velocityInView:self.view]; //get velocity of gesture recognizer
        CGFloat velocityThrowingThreshold = 500;
        
        //sets gravity depending on location of view
        if (ABS(velocity.x) > velocityThrowingThreshold)
        {
            BOOL isLeft = (velocity.x < 0);
            [self updateGravityIsLeft:isLeft];
        }
        else
        {
            BOOL isLeft = (self.trayView.frame.origin.x < self.view.center.x);
            [self updateGravityIsLeft:isLeft];
        }
    }
}

-(void)setupBehaviors
{
    UICollisionBehavior *edgeCollisionBehavior = [[UICollisionBehavior alloc]initWithItems:@[self.trayView]];
    [edgeCollisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, GUTTER_WIDTH, 0, -self.view.bounds.size.width)];
    [self.animator addBehavior:edgeCollisionBehavior];
    
    // gravity
    self.gravity = [[UIGravityBehavior alloc]initWithItems:@[self.trayView]];
    [self.animator addBehavior:self.gravity];
    [self updateGravityIsLeft:self.gravityIsLeft];
}

-(void)updateGravityIsLeft:(BOOL)isLeft
{
    CGFloat angle = isLeft ? M_PI : 0;
    [self.gravity setAngle:angle magnitude:1.0];
}

-(void)setupGestureRecognizers
{
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    edgePan.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:edgePan];
    
    UIPanGestureRecognizer *trayPanRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.trayView addGestureRecognizer:trayPanRecognizer];
}

-(void)setupTrayView
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.trayView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.trayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.trayView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    self.trayLeftEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.trayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.view.frame.size.width];
    [self.view addConstraint:self.trayLeftEdgeConstraint];
    
    UILabel *trayLabel = [UILabel new];
    trayLabel.text = @"Good Morning,\nFriend.\n\n-Yak";
    trayLabel.numberOfLines = 0;
    trayLabel.font = [UIFont systemFontOfSize:24];
    trayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.trayView addSubview:trayLabel];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[trayLabel]-(30)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(trayLabel)]];
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(100)-[trayLabel]-(100)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(trayLabel)]];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton setTitle:@"[CLOSE]" forState:UIControlStateNormal];
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.trayView addSubview:closeButton];
    
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[closeButton(==75)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    [self.trayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[closeButton(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.view layoutIfNeeded];
}

-(void)closeButtonPressed:(id)sender
{
    //one time push event
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.trayView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = 0;
    pushBehavior.magnitude = 200;
    
    [self updateGravityIsLeft:NO];
    
    [self.animator addBehavior:pushBehavior];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.animator removeAllBehaviors];
    if (self.trayView.frame.origin.x < self.view.center.x)
    {
        self.trayLeftEdgeConstraint.constant = GUTTER_WIDTH;
        self.gravityIsLeft = YES;
    }
    else
    {
        self.trayLeftEdgeConstraint.constant = size.width;
        self.gravityIsLeft = NO;
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.view layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setupBehaviors];
    }];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

