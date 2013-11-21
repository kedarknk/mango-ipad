//
//  PageNewBookTypeViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "PageNewBookTypeViewController.h"
#import "MangoEditorViewController.h"
@interface PageNewBookTypeViewController ()

@end

@implementation PageNewBookTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger)option BookId:(NSString *)bookID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _option=option;
        _bookId=bookID;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:bookID];
        _pageNumber=1;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  //  UIView *view=[MangoEditorViewController readerPage:0 ForStory:<#(NSString *)#> WithFolderLocation:<#(NSString *)#>];
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
    //  NSLog(@"json location %@",jsonLocation);
    _jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    _pageView=[MangoEditorViewController readerPage:1 ForStory:_jsonContent WithFolderLocation:_book.localPathFile];
    _pageView.frame=self.view.bounds;
    for (UIView *subview in [_pageView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
        }
    }
    _rightView.backgroundColor=[UIColor clearColor];
   // _pageView.backgroundColor=[UIColor grayColor];
   [self.viewBase addSubview:_pageView];
    NSNumber *numberOfPages = [MangoEditorViewController numberOfPagesInStory:_jsonContent];
    _pageNo=numberOfPages.integerValue;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowOptions:(id)sender {
    _rightView.hidden=NO;

    UIButton *button=(UIButton *)sender;
    button.hidden=YES;
}

- (IBAction)BackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeButton:(id)sender {
    _rightView.hidden=YES;
    _showOptionButton.hidden=NO;
}

- (IBAction)shareButton:(id)sender {
}

- (IBAction)editButton:(id)sender {
}

- (IBAction)changeLanguage:(id)sender {
}
- (IBAction)previousButton:(id)sender {
    if (_pageNumber==1) {
        [self BackButton:nil];
    }else{
        [_pageView removeFromSuperview];
        
        _pageNumber--;
        _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile];
        for (UIView *subview in [_pageView subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.frame = self.view.bounds;
            }
        }

        [self.viewBase addSubview:_pageView];

    }
}

- (IBAction)nextButton:(id)sender {
    _pageNumber++;
    if (_pageNumber<(_pageNo-1)) {
        [_pageView removeFromSuperview];
        _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile];
        for (UIView *subview in [_pageView subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.frame = self.view.bounds;
            }
        }
        
        [self.viewBase addSubview:_pageView];
    }
   
}
@end
