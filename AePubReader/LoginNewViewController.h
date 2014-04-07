//
//  LoginNewViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "SignUpViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginNewViewController : UIViewController <MangoPostApiProtocol, PostSignupDelegate, FBLoginViewDelegate>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}
- (IBAction)signIn:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)signUp:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) NSString *udid;

@end
