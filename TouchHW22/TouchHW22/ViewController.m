//
//  ViewController.m
//  TouchHW22
//
//  Created by Nikolay Berlioz on 05.11.15.
//  Copyright © 2015 Nikolay Berlioz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) UIView *viewBoard;
@property (weak, nonatomic) UIView *viewBlackCell;
@property (weak, nonatomic) UIView *draggingView;
@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGPoint pointBegunCoordinateDragView;

@property (strong, nonatomic) NSMutableArray *arrayCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayCell = [[NSMutableArray alloc] init];

    UIView *chessBoard= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 768)];
    chessBoard.backgroundColor = [UIColor brownColor];
    chessBoard.center = self.view.center;
    
    chessBoard.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:chessBoard];
   

    self.viewBoard = chessBoard;
    
    //variable
    BOOL flagVar = NO;
    CGPoint point = CGPointMake(CGRectGetMinX(self.viewBoard.bounds), CGRectGetMinY(self.viewBoard.bounds));
    
    //CHANGE COORDINATES TO CORRECT PRINT ALL VIEWS!!!!!!!!!!!!!
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            if (!flagVar)
            {
                point.x += 96;
                flagVar = YES;
            }
            else
            {
                //create black cell
                UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, 96, 96)];
                cellView.backgroundColor = [UIColor blackColor];
                [self.viewBoard addSubview:cellView];
                flagVar = NO;
                point.x += 96;
                cellView.tag = 3;
                [self.arrayCell addObject:cellView];

                //create checkers
                if (i < 3)
                {
                    UIView *whiteChecker = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cellView.frame) + 16.f,
                                                                                    CGRectGetMinY(cellView.frame) + 16.f,
                                                                                    64, 64)];
                    whiteChecker.backgroundColor = [UIColor whiteColor];
                    whiteChecker.layer.cornerRadius = 32;
                    whiteChecker.tag = 1;
                    cellView.tag = 4;//if cell is busy
                    [self.viewBoard addSubview:whiteChecker];
                }
                else if (i >4)
                {
                    UIView *redChecker = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cellView.frame) + 16.f,
                                                                                    CGRectGetMinY(cellView.frame) + 16.f,
                                                                                    64, 64)];
                    redChecker.backgroundColor = [UIColor redColor];
                    redChecker.layer.cornerRadius = 32;
                    [self.viewBoard addSubview:redChecker];
                    redChecker.tag = 2;
                    cellView.tag = 4;//if cell is busy
                }
            }
        }
        flagVar = !flagVar;
        point.x = CGRectGetMinX(self.viewBoard.bounds);
        point.y += 96;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint pointToMainView = [touch locationInView:self.view];
    
    UIView *view = [self.view hitTest:pointToMainView withEvent:event];
    
    self.pointBegunCoordinateDragView = [touch locationInView:self.viewBoard];
    
    if (view.tag == 1 || view.tag == 2) //if view white or red checker
    {
        self.draggingView = view;
        [self.viewBoard bringSubviewToFront:self.draggingView];
        
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.draggingView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                             self.draggingView.alpha = 0.5f;
                         }];
    }
    else
    {
        self.draggingView = nil;
    }
    for (UIView* viewInArray in self.viewBoard.subviews)
    {
        if (viewInArray.tag == 4)
        {
            if (CGRectIntersectsRect(self.draggingView.frame, viewInArray.frame))
            {
                viewInArray.tag = 3;//cell is free
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    if (self.draggingView)
    {
        UITouch *touch = [touches anyObject];
        CGPoint pointToChessBoard = [touch locationInView:self.viewBoard];
        
        CGPoint correction = CGPointMake(pointToChessBoard.x + self.touchOffset.x,
                                         pointToChessBoard.y + self.touchOffset.y);
        self.draggingView.center = correction;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    //assignment property Black Cell to wich Intersect with draggingView
    for (UIView* viewInArray in self.arrayCell)
    {
        if (CGRectIntersectsRect(self.draggingView.frame, viewInArray.frame))
        {
            if (viewInArray.tag == 4)
            {
                NSLog(@"Cell is busy!!!");
                self.draggingView.center = self.pointBegunCoordinateDragView;
                [UIView animateWithDuration:0.2f
                                 animations:^{
                                     self.draggingView.transform = CGAffineTransformIdentity;
                                     self.draggingView.alpha = 1.f;
                                 }];
            }
            else
            {
                self.viewBlackCell = viewInArray;
                viewInArray.tag = 4;
                self.draggingView.center = self.viewBlackCell.center;
                
                [UIView animateWithDuration:0.2f
                                 animations:^{
                                     self.draggingView.transform = CGAffineTransformIdentity;
                                     self.draggingView.alpha = 1.f;
                                 }];
            }
        }
    }
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}






























@end
