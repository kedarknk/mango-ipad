//
//  MenuTableViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/11/13.
//
//

#import "AePubReaderAppDelegate.h"
#import "Constants.h"
#import "MenuTableViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

@synthesize popDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Save & Close";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Create A New Story";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"iPad    1024 X 768 px";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Android    1280 X 800 px";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID: _bookId,
                                                 
                                                 };
                    [delegate trackEvent:[EDITOR_CLOSE valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[EDITOR_CLOSE valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [EDITOR_CLOSE valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:@"Story editor" forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:_bookId forKey:@"bookID"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];
                    
                }
                    break;
                    
                case 1: {
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID: _bookId,
                                                 
                                                 };
                    [delegate trackEvent:[EDITOR_NEW_BOOK valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[EDITOR_NEW_BOOK valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [EDITOR_NEW_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:@"Story editor" forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:_bookId forKey:@"bookID"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];
                    
                }
                    break;
                    
                case 2: {
                    
                }
                    break;
                    
                case 3: {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    [self.popDelegate goToStoriesList];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
