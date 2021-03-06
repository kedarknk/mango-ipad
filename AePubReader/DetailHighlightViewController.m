//
//  DetailHighlightViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 22/01/13.
//
//

#import "DetailHighlightViewController.h"

@interface DetailHighlightViewController ()

@end

@implementation DetailHighlightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withHighlight:(NSString *)string andNotes:(NSString *)notes
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if (notes) {
           
            _notesString=[[NSString alloc]initWithString:notes];
            
        }
        _highlightString=[[NSString alloc]initWithString:string];
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_notesLabel setAlpha:0.0];
    _notes.text=_notesString;
    _highlight.text=_highlightString;

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
       UIBarButtonItem *bar=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        self.navigationController.navigationItem.rightBarButtonItem=bar;
    
}
-(void)done:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setHighlight:nil];
    [self setNotes:nil];
    [self setNotesLabel:nil];
    [super viewDidUnload];
}
@end
