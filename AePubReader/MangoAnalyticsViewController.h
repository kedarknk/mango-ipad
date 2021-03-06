//
//  MangoAnalyticsViewController.h
//  MangoReader
//
//  Created by Harish on 3/5/14.
//
//

#import "DropDownView.h"
#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface MangoAnalyticsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, DropDownViewDelegate>{
    
    NSString *storyAsAppFilePath;
    int validUserSubscription;

}

@property (nonatomic, strong) IBOutlet UILabel *labelUserLastStories;
@property (nonatomic, strong) IBOutlet UILabel *labelUserSnapshot;

@property (nonatomic, strong) IBOutlet UILabel *labelTotalTimeSpent;
@property (nonatomic, strong) IBOutlet UILabel *labelStoriesCompleted;
@property (nonatomic, strong) IBOutlet UILabel *labelTotalPagesRead;
@property (nonatomic, strong) IBOutlet UILabel *labelAllActivities;

@property (nonatomic, strong) NSArray *arrayCollectionData;

@property (nonatomic,retain) IBOutlet UIButton *dropDownButton;
@property (nonatomic, retain) NSMutableArray *dropDownArrayData;
@property (nonatomic, retain) DropDownView *dropDownView;
@property (nonatomic, strong) IBOutlet UICollectionView *bookDataDisplayView;

@property (nonatomic, strong) NSString *loginUserEmail;
@property (nonatomic,retain) IBOutlet UIButton *loginButton;

-(IBAction)backView:(id)sender;

-(IBAction)dropDownActionButtonClick;
- (IBAction)logoutUser:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *subview;
-(IBAction)hide;

@end
