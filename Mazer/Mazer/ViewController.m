//
//  ViewController.m
//  Mazer
//
//  Created by Tom Adriaenssen on 05/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "ViewController.h"
#import "Maze.h"
#import "DepthFirstAlgorithm.h"
#import "MBProgressHUD.h"

@interface ViewController () <UIPrintInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mazeView;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (weak, nonatomic) IBOutlet UISlider *lengthSlider;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) Maze* maze;

@end

@implementation ViewController {
    NSOperationQueue* _queue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _queue = [NSOperationQueue new];
    _queue.maxConcurrentOperationCount = 1;

    uint size = MAX(floorf(self.sizeSlider.value), 10);
    self.sizeLabel.text = [NSString stringWithFormat:@"%d", size];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self generateMazeWithSliderSize];
}

- (void)updateMaze {
    UIImage* image = [self.maze draw:self.mazeView.bounds.size lineWidth:IsIPad() ? 3 : 1 lineColor:[UIColor blackColor]];
    self.mazeView.image = image;
}

- (IBAction)regenerateMaze:(id)sender {
    [self regenerateMazeCompletion:nil];
}

- (void)regenerateMazeCompletion:(void(^)(void))completion {
    [self.maze generateMazeHoleFactor:0.05 callback:^{
//        [NSThread sleepForTimeInterval:0.5];
//        dispatch_async_main(^{
//            [self updateMaze];
//        });
    } completion:^{
        dispatch_async_main(^{
            [self updateMaze];
            if (completion)
                completion();
        });
    }];
}

- (IBAction)print:(UIButton*)sender {
    UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
    printController.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"maze.pdf";
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printController.printInfo = printInfo;
    printController.showsPageRange = YES;
    
    printController.printingItem = [self.maze draw:(CGSize) { 1000, 1000 } lineWidth:5 lineColor:[UIColor blackColor]];
    
    [printController presentFromRect:sender.frame inView:self.view animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
    }];
}

- (IBAction)lengthSliderChanged:(UISlider*)sender {
    [self sizeSliderChanged];
}

- (IBAction)sizeSliderChanged {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_queue cancelAllOperations];
    __block NSOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        if ([operation isCancelled])
            return;

        [self generateMazeWithSliderSize];
    }];
    [_queue addOperation:operation];
}

- (void)generateMazeWithSliderSize {
    uint size = MAX(floorf(self.sizeSlider.value), 10);
    self.maze = [[Maze alloc] initWithWidth:size height:size algorithm:[[DepthFirstAlgorithm alloc] initWithStretchFactor:self.lengthSlider.value] generate:NO];
    [self regenerateMazeCompletion:^{
        self.sizeLabel.text = [NSString stringWithFormat:@"%d", size];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

@end
