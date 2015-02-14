//
//  FinishReadingViewController.h
//  MangoReader
//
//  Created by Harish on 1/15/15.
//
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "Constants.h"
#import "MangoApiController.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@interface FinishReadingViewController : UIViewController<MangoPostApiProtocol,GADBannerViewDelegate>

@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;

@property(strong, nonatomic) NSString *totalWords;
@property(strong, nonatomic) NSString *totalTime;
@property (strong, nonatomic) IBOutlet UILabel *timeTakenValue;

@property (strong , nonatomic) IBOutlet UIView *bookDownloadView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *bookDownloadingActivity;
@property (nonatomic, strong) GADBannerView *bannerView_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withId :(NSString*)identity;

- (IBAction) dismissToHomePage:(id)sender;

- (IBAction) startReadingNewbook:(id)sender;

- (GADRequest *)request;

@end
