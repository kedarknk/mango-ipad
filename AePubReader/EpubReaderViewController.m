
#import "EpubReaderViewController.h"
#import "NotesHighlightViewController.h"
#import "AePubReaderAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "WebViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "UIWebView+SearchWebView.h"
@implementation EpubReaderViewController
@synthesize _ePubContent;
@synthesize _rootPath;
@synthesize _strFileName;
-(void)removeZoom:(UIView *)view{
    for (UIView *v in [view subviews])
    {
        if (v != view)
        {
            [self removeZoom:v];
        }
    }
    for (UIGestureRecognizer *reco in [view gestureRecognizers])
    {
        if ([reco isKindOfClass:[UITapGestureRecognizer class]])
        {
            if ([(UITapGestureRecognizer *)reco numberOfTapsRequired] == 2)
            {
                NSLog(@"Remove zoom");
                [view removeGestureRecognizer:reco];
            }
        }
    }


}
-(void)goToPage:(id)sender{
    UIButton *button=(UIButton *)sender;
    NSLog(@"tag %d",button.tag);
    if (button.tag==_pageNumber) {
        return;
    }
    _pageNumber=button.tag;
    [self loadPage];
    
    
}
-(void)addThumbnails{
  //  NSLog(@"file location %@",_rootPath);
 

    NSFileManager *defaultManager=[NSFileManager defaultManager];
      NSInteger index;
  //  UIImage *image=[UIImage imageNamed:@"footer-bg.png"];
 //   _scrollViewForThumnails.backgroundColor= [UIColor colorWithPatternImage:image];
   // self.view.backgroundColor=[UIColor colorWithPatternImage:image];
    NSString *thumbNailLocation=[_rootPath stringByAppendingPathComponent:@"thumbnails"];
    if ( [defaultManager fileExistsAtPath:thumbNailLocation]) {
       NSArray *array= [defaultManager contentsOfDirectoryAtPath:thumbNailLocation error:nil];
        NSLog(@"count %d",array.count);
        NSMutableArray *arrayMutable=[[NSMutableArray alloc]initWithCapacity:array.count];
        
        for (index=0; index<_ePubContent._spine.count; index++) {
           // NSString *val=[[NSString alloc]initWithFormat:@"pg%d.jpg",index+1 ];
            NSString  *actual=[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:index]];
            actual =[actual stringByDeletingPathExtension];
            NSString *val=[actual stringByAppendingString:@".png"];
           //  NSLog(@"spine at %d %@ %@",index,val,[self._ePubContent._spine objectAtIndex:index]);
            [arrayMutable addObject:val];
            //[val release];
        }
        array=[NSArray arrayWithArray:arrayMutable];
      //  [arrayMutable release];
        //  array=  [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
      CGSize size=  _scrollViewForThumnails.contentSize;
        CGFloat width=array.count *200;
        //NSString *deviceType=[UIDevice currentDevice].model;
        NSInteger widthThum;
        NSInteger heightThum;
        NSInteger x;
        NSInteger y;
      
        NSInteger increment;
        for (UIView *view in _scrollViewForThumnails.subviews) {
            [view removeFromSuperview];
        }
        
//_scrollViewForThumnails.backgroundColor=[UIColor blackColor]; topbottom.png
        UIImage *image=[UIImage imageNamed:@"footer-bg.png"];
        _scrollViewForThumnails.backgroundColor= [UIColor colorWithPatternImage:image];

     //   [_scrollViewForThumnails setHidden:YES];
         increment=100;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            width=array.count;
            size.width=width*increment;
            _scrollViewForThumnails.contentSize=size;
            widthThum=85;
            heightThum=66;
            y=10;
            x=20;
        }else{
            increment=150;
            width=array.count;
            width=width*increment;
            if (width>1024) {
                size.width=width;
                _scrollViewForThumnails.contentSize=size;
            }
            widthThum=135;//170
            heightThum=105;//132
            y=15;
            x=20;
        }
        for (index=0;index<_ePubContent._spine.count;index++) {
            NSString *imageLoc=[array objectAtIndex:index];
            CGRect rect=CGRectMake(x, y, widthThum, heightThum);
            UIButton *button=[[UIButton alloc]initWithFrame:rect];
            imageLoc=[thumbNailLocation stringByAppendingPathComponent:imageLoc];
            UIImage *image=[[UIImage alloc]initWithContentsOfFile:imageLoc];
            //NSLog(@"location %@",imageLoc);
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(goToPage:) forControlEvents:UIControlEventTouchUpInside];
            if (index==_pageNumber) {
                [[button layer] setBorderWidth:4.0f];
                float red=81.0/255.0;
                float green=156.0/255.0;
                
                UIColor *color=[UIColor colorWithRed:red green:green blue:0 alpha:1.0];
                
                [[button layer]setBorderColor:color.CGColor];
            }
            else{
                [[button layer] setBorderWidth:1.0f];
                float red=166.0/255.0;
                float green=131.0/255.0;
                UIColor *color=[UIColor colorWithRed:red green:green blue:0 alpha:1.0];
                
                [[button layer]setBorderColor:color.CGColor];
            }
            [_scrollViewForThumnails addSubview:button];
            button.tag=index;
           // [button release];
           // [image release];
            x+=increment;
            
        }

        
    }
    
    
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{

    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    UIImage *image=[UIImage imageNamed:@"top.png"];
    UIColor *color=[UIColor colorWithPatternImage:image];
    _imageToptoolbar.backgroundColor=color;
    image=[UIImage imageNamed:@"side.png"];
   color=[UIColor colorWithPatternImage:image];
    _recordBackgroundview.backgroundColor=color;
    _hide=YES;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        NSString *string=[NSString stringWithFormat:@"ipad Story Book reading titled %@  with id %d started",_titleOfBook,[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] ];
        
        [Flurry logEvent:string];
    }else{
        NSString *string=[NSString stringWithFormat:@"iphone or ipod touch Store Book reading titled %@  with id %d started",_titleOfBook,[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] ];
        
        [Flurry logEvent:string];
    }

    [_recordButton addTarget:self action:@selector(wasDragged:withEvent:)  forControlEvents:UIControlEventTouchDragInside];
	[_webview setBackgroundColor:[UIColor clearColor]];
	//First unzip the epub file to documents directory
	//[self unzipAndSaveFile];
	_xmlHandler=[[XMLHandler alloc] init];
	_xmlHandler.delegate=self;
	[_xmlHandler parseXMLFileAt:[self getRootFilePath]];
    [_leftButton setAlpha:0.25f];
    [_rightButton setAlpha:0.25f];
   
      [self removeZoom:_webview];
    UISwipeGestureRecognizer *left=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    left.direction=UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *right=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    right.direction=UISwipeGestureRecognizerDirectionLeft;
    [_webview.scrollView addGestureRecognizer:left];
    [_webview.scrollView addGestureRecognizer:right];

    [_shareButton setTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar addSubview:_textField];

    [self.navigationController.navigationBar setHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
    [_webview setDelegate:self];

    NSLog(@"height %f",_webview.frame.size.height);
    NSString *temp=[_strFileName stringByDeletingPathExtension];
    if([[NSFileManager defaultManager]fileExistsAtPath:temp]){
        [[NSURL URLWithString:temp] setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    NSString *gameLink=[_rootPath stringByAppendingPathComponent:@"game.html"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:gameLink]) {
        [_gameButton setEnabled:YES];
        _gameLink=[[NSString alloc]initWithString:gameLink];
    }else{
        [_gameButton setEnabled:NO];
    }
    NSLog(@"superview ht %f",self.view.frame.size.height);
    _webview.scrollView.bounces=NO;
    _webview.scrollView.alwaysBounceHorizontal=NO;

    
    _webview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [_doneButton setTintColor:[UIColor lightGrayColor]];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        _topToolbar.tintColor=[UIColor blackColor];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   // CGFloat screenWidth=screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
   // CGFloat screenWidht=screenRect.size.width;
    if (screenHeight>500.0&& [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
      CGRect rect=  _imageToptoolbar.frame;
        rect.size.width=1136.0;
        _imageToptoolbar.frame=rect;
       rect= _recordBackgroundview.frame;
        rect.origin.x=568.0;
        _recordBackgroundview.frame=rect;
        rect=_scrollViewForThumnails.frame;
        rect.size.width=1136.0;
        _scrollViewForThumnails.frame=rect;
        rect=_nextButton.frame;
        rect.origin.x=521.0;//433
        _nextButton.frame=rect;
        rect=_showRecordButton.frame;
        rect.origin.x=rect.origin.x+98;
        _showRecordButton.frame=rect;
        rect=_playPauseControl.frame;
        rect.origin.x=rect.origin.x+98;
        _playPauseControl.frame=rect;
        rect=_gameButton.frame;
        rect.origin.x=rect.origin.x+98;
        _gameButton.frame=rect;
        
        
    }
    _wasFirstInPortrait=NO;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        NSLog(@"still in portrat");
        UIViewController *c=[[UIViewController alloc]init];
 
        [self presentViewController:c animated:NO completion:^(void){
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        _wasFirstInPortrait=YES;
 

    }else{
    
        NSLog(@"landscape");
    }
    _hide=YES;
    _record=NO;
    _topToolbar.hidden=YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled==YES) {
        // Set up an observer for proximity changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                     name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
    [_stopButton setHidden:YES];
    [_playRecordedButton setEnabled:NO];
    if( UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        _progressView=[[CircularProgressView alloc]initWithFrame:CGRectMake(9, 29, 66, 66)];
    }else{
        _progressView=[[CircularProgressView alloc]initWithFrame:CGRectMake(7, 7, 35,35)];

    }
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopRecord:)];
    [_progressView addGestureRecognizer:tap];
    [_recordBackgroundview addSubview:_progressView];
    
    [_recordBackgroundview bringSubviewToFront:_playRecordedButton];
    [_progressView setProgress:0.0f];
    [_progressView setHidden:YES];

}
- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event{
    //get the touch
    UITouch *touch=[[event touchesForView:button] anyObject];
    //get delta
    CGPoint previousLocation=[touch previousLocationInView:button];
    CGPoint location=[touch locationInView:button];
    CGFloat delta_x=location.x-previousLocation.x;
    CGFloat delta_y=location.y-previousLocation.y;
    button.center=CGPointMake(button.center.x+delta_x,button.center.y+delta_y);
}
-(void)stopRecord:(id)sender{
    [_anAudioRecorder stop];
    [_playRecordedButton setEnabled:YES];
    [_progressView setHidden:YES];
    [_timerProgress invalidate];
    UIImage *image=[UIImage imageNamed:@"start-recording-control.png"];
    [_recordAudioButton setImage:image forState:UIControlStateNormal];
    if (_anAudioPlayer) {
        _anAudioPlayer=nil;
    }
//    UIImage *image=[UIImage imageNamed:@"start-recording-control.png"];
//    [_playRecordedButton setImage:image forState:UIControlStateNormal];

}
-(void)showDay{
    _DayOrNight=YES;
     [_webview stringByEvaluatingJavaScriptFromString:@"showDay()"];
}
-(void)showNight{
    _DayOrNight=NO;
     [_webview stringByEvaluatingJavaScriptFromString:@"showNight()"];
}
//- (IBAction)checkluminosity:(id)sender {
//    [_videoCamera startCameraCapture];
//}

-(void)shakeEvent{
    
}
-(void)sensorStateChange:(NSNotification *)notification
{
    if ([[UIDevice currentDevice]proximityState]==YES) {
        
        
    }else{
        
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action==@selector(highlight:)) {
        return NO;
    }
    if (action==@selector(notes:)) {
        return NO;
    }
    return  [super canPerformAction:action withSender:sender];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)notes:(id)sender{


}
-(IBAction)removeHighlight:(id)sender{
[_webview stringByEvaluatingJavaScriptFromString:@"uiWebview_RemoveAllHighlights()"];
}
-(IBAction)highlight:(id)sender{
  
    // The JS File
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"HighlightedString" ofType:@"js" inDirectory:@""];
    NSData *fileData    = [NSData dataWithContentsOfFile:filePath];
    NSString *jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    [_webview stringByEvaluatingJavaScriptFromString:jsString];
    NSString *selectedText   = [NSString stringWithFormat:@"window.getSelection().toString()"];
    NSString * highlightedString = [_webview stringByEvaluatingJavaScriptFromString:selectedText];
    // The JS Function
    NSString *startSearch   = [NSString stringWithFormat:@"stylizeHighlightedString()"];
    [_webview stringByEvaluatingJavaScriptFromString:startSearch];
    //[jsString release];
    if (selectedText.length>2) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.dataModel insertNoteOFHighLight:YES book:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] page:_pageNumber string:highlightedString];
    }


    
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    if (_alertView) {
//        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
//        _alertView=nil;
//
    NSLog(@"%@",error);
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request %@",[[request URL]absoluteString]);
    if ([[[request URL]absoluteString]hasPrefix:@"playingcompleted:"]) {
        [self playingEnded];
        return NO;
    }
    if ([[[request URL] absoluteString]hasPrefix:@"startplaying"]) {
        UIImage *image=[UIImage imageNamed:@"pause-control.png"];
        [_playPauseControl setImage:image forState:UIControlStateNormal];
        NSString *jsCode=@"$('#jquery_jplayer').jPlayer('play')";
        [_webview stringByEvaluatingJavaScriptFromString:jsCode];
        return NO;
    }
    if ([[[request URL] absoluteString] hasPrefix:@"checkevaluate"]) {
        [self readyState];
        return NO;
        
    }
    return YES;
}
-(void)readyState{

   NSString  *jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"function tryout(){if(document.getElementById('jquery_jplayer')){return true}} tryout()"];
  
    NSLog(@" %@",jsCode);
    if ([jsCode isEqualToString:@"true"]) {
        
        if (_shouldAutoPlay) {
            
            
//            jsCode= @"$('#jquery_jplayer').bind($.jPlayer.event.ready, function(event) {  window.location =\"startPlaying:myObjectiveCFunction\";});";
            jsCode=@"$('#jquery_jplayer').jPlayer('play')";
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
            [_webview stringByEvaluatingJavaScriptFromString:jsCode];
            _isPlaying=YES;
            //EpubReaderViewController
        }
        else{
            _isPlaying=NO;
        }
        jsCode=@" $('#jquery_jplayer').bind($.jPlayer.event.ended, function(event) {  window.location = \"playingCompleted:myObjectiveCFunction\";});";
        [_webview stringByEvaluatingJavaScriptFromString:jsCode];
        
        [_playPauseControl setEnabled:YES];
    }else{
        [_playPauseControl setEnabled:NO];
    }

}
-(void)AlternativetoPlayAudio{
    [self readyState];
      NSString *value=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
    if (value.length==0) {
        [self readyState];
        _isOld=YES;
    }else{
        NSString  *jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"function tryout(){if(document.getElementById('jquery_jplayer')){return true}} tryout()"];
        
        NSLog(@" %@",jsCode);
        if ([jsCode isEqualToString:@"false"]) {
            [_playPauseControl setEnabled:NO];

        }else{
             [_playPauseControl setEnabled:YES];
        }
       /*      NSString *path=[_rootPath stringByAppendingPathComponent:value ];
        
        NSError *error;
       _playerDefault=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
        _playerDefault.delegate=self;
        [_playerDefault play];*/
       _timer= [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        _isOld=NO;
    }

    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _pageLoaded=NO;
    NSString *jsCode;
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {

        webView.scrollView.bounces=NO;
       // [webView.scrollView setScrollEnabled:NO];
        jsCode=@"<meta name=\"viewport\" content=\"width=device-width\" />";
        [webView stringByEvaluatingJavaScriptFromString:jsCode];
        webView.scrollView.delegate=self;
     
    }
    [UIView animateWithDuration:2.0 animations:^(void) {
        
        [_leftButton setAlpha:1.0f];
        [_rightButton setAlpha:1.0f];
        
    }];
    [UIView animateWithDuration:1.0 animations:^(void) {
        
        [_leftButton setAlpha:0.25f];
        [_rightButton setAlpha:0.25f];
        
    }];
    if ([self._ePubContent._spine count]-1==_pageNumber) {
        _rightButton.hidden=YES;
    }else{
        _rightButton.hidden=NO;
    }
    
    _isPlaying=NO;
    jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"localStorage.autoPlay"];
    NSLog(@"autoPlay value %@",jsCode);
    if ([jsCode isEqualToString:@"1"]) {
        _shouldAutoPlay=YES;
#pragma mark audio
    
     //   [self performSelector:@selector(AlternativetoPlayAudio) withObject:nil afterDelay:1];
    }else if([jsCode isEqualToString:@"0"]){
        _shouldAutoPlay=NO;
    }
        [self performSelector:@selector(readyState) withObject:nil afterDelay:3];
   

    NSLog(@"pageNumber %d",_pageNumber);
    CGSize size=webView.scrollView.contentSize;
    size.width=1024;
    [webView.scrollView setContentSize:size];
    NSString *page=[[webView.request.URL absoluteString] lastPathComponent];
    NSLog(@"path %@",page);
    for (int i=0;i<_ePubContent._spine.count;i++) {
        NSString *temp=[_ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:i]];
        //NSLog(@"temp %@",temp);
        if ([temp isEqualToString:page]) {
            if (i!=_pageNumber) {
                _pageNumber=i;
                NSLog(@"pagenumber %d",_pageNumber);
            }
            break;
        }
        
    }
    [self addThumbnails];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        NSString *height=[_webview stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight"];

        if (height.integerValue<800) {
            _webview.scrollView.scrollEnabled=NO;
        }
        
    }
    
    if (_pageNumber==0) {
        _leftButton.hidden=YES;
        _rightButton.hidden=YES;
    }else{
        _leftButton.hidden=NO;
        _rightButton.hidden=NO;
    }
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    NSString *appenLoc=[[NSString alloc] initWithFormat:@"%d",iden];
    path=[path stringByAppendingPathComponent:appenLoc];
    appenLoc=[[NSString alloc]initWithFormat:@"%d.ima4",_pageNumber ];

    path=[path stringByAppendingPathComponent:appenLoc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [_playRecordedButton setEnabled:NO];
    }else{
        [_playRecordedButton setEnabled:YES];
    }
    _anAudioPlayer=nil;

}
-(void)update{
   // NSLog(@"seconds %f",_playerDefault.deviceCurrentTime);
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
   
//    _alertView =[[UIAlertView alloc]init];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
//    [_alertView setTitle:@"Loading...."];
//    [_alertView show];
}
-(void)viewDidDisappear:(BOOL)animated{
   
    [self.tabBarController.tabBar setHidden:NO];
    NSString *value=[_strFileName stringByDeletingPathExtension];
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:@"locDirectory"];
    if ([_anAudioPlayer isPlaying]) {
        [_anAudioPlayer stop];
    }
    if ([_timer isValid]) {
        [_timer invalidate];
    }
   /* if ([_playerDefault isPlaying]) {
        [_playerDefault stop];
        _playerDefault=nil;
    }*/
    
}
/*Function Name : setTitlename
 *Return Type   : void
 *Parameters    : NSString- Text to set as title
 *Purpose       : To set the title for the view
 */

- (void)setTitlename:(NSString*)titleText{
	
	// this will appear as the title in the navigation bar
	CGRect frame = CGRectMake(0, 0, 200, 44);
	UILabel *label = [[UILabel alloc] initWithFrame:frame] ;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:17.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines=0;
	label.textColor=[UIColor whiteColor];
	self.navigationItem.titleView = label;
	label.text=titleText;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
 /*   if (![_playerDefault isPlaying]) {
        [_playerDefault play];
    }*/
   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
       [self becomeFirstResponder];
}

   /*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
*/

- (void)unzipAndSaveFile{
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:_strFileName] ){
		 NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
		//NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		NSString *strPath=[NSString stringWithFormat:@"%@/%d",[self applicationDocumentsDirectory],iden];
        //Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
	//	[filemanager release];
		filemanager=nil;
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
	//		[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}
	//[za release];
    
}

/*Function Name : applicationDocumentsDirectory
 *Return Type   : NSString - Returns the path to documents directory
 *Parameters    : nil
 *Purpose       : To find the path to documents directory
 */

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
      [searchBar resignFirstResponder];
    NSLog(@"search Button Clicked");
}
/*Function Name : getRootFilePath
 *Return Type   : NSString - Returns the path to container.xml
 *Parameters    : nil
 *Purpose       : To find the path to container.xml.This file contains the file name which holds the epub informations
 */

- (NSString*)getRootFilePath{
	
	//check whether root file path exists
	NSFileManager *filemanager=[[NSFileManager alloc] init];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
	//NSString *strFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml",[self applicationDocumentsDirectory]];
    NSString *strFilePath=[NSString stringWithFormat:@"%@/%d/META-INF/container.xml",[self applicationDocumentsDirectory],iden];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
		//[filemanager release];
		filemanager=nil;
		
		return strFilePath;
	}
	else {
		
		//Invalid ePub file
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"Delete the book and download it again"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
	//	[alert release];
		alert=nil;
		
	}
	//[filemanager release];
	filemanager=nil;
	return @"";
}

- (IBAction)backButtonOrNextButton:(id)sender {
    UIButton *btnClicked=(UIButton*)sender;
    [btnClicked setAlpha:1.0f];
	if (btnClicked.tag==0) {
		
		if (_pageNumber>0) {
			
			_pageNumber--;
          //  [_playerDefault stop];
          //  _playerDefault=nil;
			[self loadPage];
		}else{
      [self onBack:nil];
        }

	}
	else {
		
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
          //  [_playerDefault stop];
          //  _playerDefault=nil;
			[self loadPage];
		}
	}

}

#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	//NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];

    NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/%d/%@",[self applicationDocumentsDirectory],iden,rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self._rootPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
        _anotherHandlerOPF=[[XMLHandler alloc] init];
        _anotherHandlerOPF.delegate=self;
		[_anotherHandlerOPF parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		//[alert release];
		alert=nil;
	}
	//[filemanager release];
	filemanager=nil;
	
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
   
    return  UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(BOOL)shouldAutorotate{
    return YES;
}
- (void)finishedParsing:(EpubContent*)ePubContents{

	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self._ePubContent=ePubContents;
	_pageNumber=0;
	[self loadPage];
    [self addThumbnails];
 
}

-(void)leftOrRightGesture:(UISwipeGestureRecognizer *)gesture{
    _topToolbar.hidden=YES;
    
    if (gesture.direction==UISwipeGestureRecognizerDirectionRight) {
		NSLog(@"Right swipe");
        
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}else{
            [self onBack:nil];
        }
	}
	else {
		NSLog(@"Left swipe");
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
			[self loadPage];
		}
	}

}
#pragma mark Button Actions

- (IBAction)onPreviousOrNext:(id)sender{
	
	
	UIBarButtonItem *btnClicked=(UIBarButtonItem*)sender;
	if (btnClicked.tag==0) {
		
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}
	}
	else {
		
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
			[self loadPage];
		}
	}
}

- (IBAction)onBack:(id)sender{

    [self.navigationController.navigationBar setHidden:NO];
    self.navigationController.navigationBarHidden=NO;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
                           [_webview loadRequest:request];
[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self.navigationController popViewControllerAnimated:YES];
    NSLog(@"NSString %@",_strFileName);

    if (_pop) {
        [_pop dismissPopoverAnimated:YES];
    }
    [self stopRecording:nil];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        NSString *string=[NSString stringWithFormat:@"ipad Story Book closed titled %@  with id %d  at page Number %d ",_titleOfBook,[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"],_pageNumber ];
        [Flurry logEvent:string];
    }else{
        NSString *string=[NSString stringWithFormat:@"iphone or ipod touch  Story Book closed titled %@  with id %d  at pageNumber %d",_titleOfBook,[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"],_pageNumber ];
        [Flurry logEvent:string];
    }

    
}

- (IBAction)showPopView:(id)sender {
   // NSString *deivceType=[UIDevice currentDevice].model;
    UINavigationController *nav;
    NotesHighlightViewController *notes=[[NotesHighlightViewController alloc]initWithStyle:UITableViewStyleGrouped With:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] withPageNo:_pageNumber];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:notes animated:YES];
       // [notes release];
        
        
    }else{
        nav=[[UINavigationController alloc]initWithRootViewController:notes];
       // [notes release];

       _pop=[[UIPopoverController alloc]initWithContentViewController:nav];
    [_pop presentPopoverFromBarButtonItem:_showPop permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //[nav release];
    }
    
}

- (IBAction)playOrPauseAudio:(id)sender {

   // if (_isOld) {
        
   
        if (!_isPlaying) {
        
      
            [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('play')"];
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
            [self ribbonButtonClick:nil];
        
        }else{
        
            [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('pause')"];
            UIImage *image=[UIImage imageNamed:@"play-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];

        }
        _isPlaying=!_isPlaying;
   // }else{
     /*   if (_playerDefault) {
            if (_pageLoaded) {
                NSError *error;
                NSString *value=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
                NSString *path=[_rootPath stringByAppendingPathComponent:value ];
                _playerDefault=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
                _playerDefault.delegate=self;
                [_playerDefault play];
                UIImage *image=[UIImage imageNamed:@"pause-control.png"];
                [_playPauseControl setImage:image forState:UIControlStateNormal];
                [self ribbonButtonClick:nil];
            }
            if ([_playerDefault isPlaying]) {
                [_playerDefault pause];
                UIImage *image=[UIImage imageNamed:@"play-control.png"];
                [_playPauseControl setImage:image forState:UIControlStateNormal];
            }else{
                [_playerDefault play];
                UIImage *image=[UIImage imageNamed:@"pause-control.png"];
                [_playPauseControl setImage:image forState:UIControlStateNormal];
                [self ribbonButtonClick:nil];
            }*/
            
            
            
     //   }
      //  else{
      //      NSString *value=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
       /*     NSString *path=[_rootPath stringByAppendingPathComponent:value ];
            NSError *error;
            
            _playerDefault=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
            _playerDefault.delegate=self;
            [_playerDefault play];*/
         /*   UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
            [self ribbonButtonClick:nil];*/
        //}
        
        
        
 //   }
    
}
-(void)playingEnded{
    _isPlaying=NO;
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    NSLog(@"PLAYING ENDED");
}

- (IBAction)recordAudio:(id)sender {

[Flurry logEvent:[NSString stringWithFormat:@"recording start for book of id %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"]]];
  
    if(!_record){
        [UIView animateWithDuration:1.0 animations:^{
              CGRect frame;
            frame=  _recordBackgroundview.frame;
            frame.origin.x=frame.origin.x-frame.size.width;
            _recordBackgroundview.frame=frame;
        }];
        [self ribbonButtonClick:nil];
        
    }else{
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame;
            frame=  _recordBackgroundview.frame;
            frame.origin.x=frame.origin.x+frame.size.width;
            _recordBackgroundview.frame=frame;
        }];
    }
    _record=!_record;

}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [_timerProgress invalidate];
   // [_anAudioRecorder release];
 
   // _anAudioRecorder=nil;
    if (_anAudioPlayer) {
        _anAudioPlayer=nil;
    }
    UIImage *image=[UIImage imageNamed:@"start-recording-control.png"];
    [_recordAudioButton setImage:image forState:UIControlStateNormal];
  [_recordAudioButton setEnabled:YES];

}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Error %@",error);
 //   [_anAudioRecorder release];
 //   _anAudioPlayer=nil;
    
}
/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:_pageNumber]]];
	[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
    [self addThumbnails];
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}

#pragma mark Memory handlers

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setRecordButton:nil];
    [self setPlayRecordedButton:nil];
    [self setStopButton:nil];
    [self setRightButton:nil];
    [self setLeftButton:nil];
  //  [_videoCamera stopCameraCapture];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    // Set up an observer for proximity changes
 
    [self setShowRecordButton:nil];
    [self setNextButton:nil];
    [self setGameButton:nil];
    
    [self setRecordAudioButton:nil];
    [self setRecordBackgroundview:nil];
    [self setPlayPauseControl:nil];
    [self setToggleToolbar:nil];
    [self setImageToptoolbar:nil];
   

    [self setShowPop:nil];
    [self setScrollViewForThumnails:nil];
    
    [self setShareButton:nil];
    [self setDoneButton:nil];
    [self setTopToolbar:nil];

    [self setView:nil];
  
    _webview = nil;

}



- (IBAction)hideSearch:(id)sender {
 
}
- (IBAction)shareTheBook:(id)sender {
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
    NSString *textToShare=[_url stringByAppendingString:@" great bk from MangoReader"];
    
   
    UIImage *image=[UIImage imageWithContentsOfFile:_imageLocation];
    NSArray *activityItems=@[textToShare,image];
    
    UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:activity animated:YES];
          //  [activity release];
            return;
        }
    UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:activity];
    
  //  [activity release];
        [pop presentPopoverFromBarButtonItem:_shareButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        // you dont release this
        return;
    }
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;

    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",[_url stringByAppendingString:@" great bk from MangoReader"]];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
  //  [mail release];

    
}

- (IBAction)ribbonButtonClick:(id)sender {
    NSLog(@"ribbonButton Click is called");
    if ([_anAudioRecorder isRecording]) {// nil assumption based on recording.
        
        NSLog(@"Recording is on");
        return;
    }
 if(_record&&sender){
     NSLog(@"recordAudio called");
            [self recordAudio:nil];
        }
      NSString *model=[UIDevice currentDevice].model;
    if (_hide&&sender) {// if hidden
          NSLog(@"hide is true");

        [UIView animateWithDuration:1.0 animations:^{
          //_imageToptoolbar
            CGRect frame=_imageToptoolbar.frame;
            frame.origin.y=0;
            _imageToptoolbar.frame=frame;
            
            frame=_toggleToolbar.frame;
            if ([model hasPrefix:@"iPad"]) {
                 frame.origin.y=_imageToptoolbar.frame.size.height-4;
            }else{
                frame.origin.y=_imageToptoolbar.frame.size.height-1;
            }
           
            _toggleToolbar.frame=frame;
            frame=_scrollViewForThumnails.frame;
            frame.origin.y=frame.origin.y-_scrollViewForThumnails.frame.size.height;
            _scrollViewForThumnails.frame=frame;
          
            _hide=!_hide;// reason in if is due to scheduling, which is a must
        }];

        NSLog(@"ribbonButton click scheduled");// only time scheduling is when the topbar is shown.
            [self performSelector:@selector(ribbonButtonClick:) withObject:nil afterDelay:15];
        [_leftButton setAlpha:1.0f];
        [_rightButton setAlpha:1.0f];
    }

    else if(!_hide){// simple reason to have else if instead of else is that call to this function is at times schedules with perform selector
        [_leftButton setAlpha:0.25f];
        [_rightButton setAlpha:0.25f];
        NSLog(@"hide is not true");
        [UIView animateWithDuration:1.0 animations:^{
            //_imageToptoolbar
            CGRect frame=_imageToptoolbar.frame;
              frame.origin.y=-_imageToptoolbar.frame.size.height;
            if ([model hasPrefix:@"iPad"]) {
                frame.origin.y=frame.origin.y+3;
            }
            _imageToptoolbar.frame=frame;
            frame=_toggleToolbar.frame;
            frame.origin.y=-1;
            _toggleToolbar.frame=frame;
            frame=_scrollViewForThumnails.frame;
            frame.origin.y=frame.origin.y+_scrollViewForThumnails.frame.size.height;
            _scrollViewForThumnails.frame=frame;
            _hide=!_hide;// reason in if is due to scheduling, which is a must

        }];
      
    }
   
    

}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
#pragma mark GameViewController
- (IBAction)openGame:(id)sender {
    if (_isPlaying) {
        
    
    [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('pause')"];
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
        _isPlaying=NO;
    }
    _gameLink=[_gameLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   NSURL *url= [NSURL URLWithString:_gameLink];
    WebViewController *web;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
      web=  [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    }else{
      web  =[[WebViewController alloc]initWithNibName:@"WebViewControllerIphone" bundle:nil URL:url];}
    [self presentModalViewController:web animated:YES];
   // [web release];
    
}
//-(NSUInteger)supportedInterfaceOrientations{
//       NSLog(@"EpubSupported Supported");
//    return UIInterfaceOrientationMaskLandscape;
//}

#pragma mark recording
- (IBAction)startRecording:(id)sender {
    UIButton *recordButton=(UIButton *)sender;
  //  [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('stop')"];
    
    if (![_anAudioRecorder isRecording]) {
        if (_isPlaying) {
            [self playOrPauseAudio:nil];
        }
        if ([_anAudioPlayer isPlaying]) {
            [self playRecorded:nil];
        }
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatAppleIMA4],
                                        AVFormatIDKey,
                                        [NSNumber numberWithInt: 1],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
        
        // Get temp path name
        
        NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
        NSString *appenLoc=[[NSString alloc] initWithFormat:@"%d",iden];
        path=[path stringByAppendingPathComponent:appenLoc];
    //    [appenLoc release];
        NSError *error;
        if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
             [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"error %@",error);
            }
        }
       appenLoc=[[NSString alloc]initWithFormat:@"%d.ima4",_pageNumber ];
        
        NSString *loc=[path stringByAppendingPathComponent:appenLoc];
       
     //   [appenLoc release];
        if ([[NSFileManager defaultManager] fileExistsAtPath:loc]) {
            [[NSFileManager defaultManager]removeItemAtPath:loc error:&error];
            if (error) {
                NSLog(@"error %@",error);
    
            }
        }
        NSURL *audioFileURL = [NSURL fileURLWithPath:loc];
        _anAudioRecorder= [[AVAudioRecorder alloc] initWithURL:audioFileURL
                                                      settings:recordSettings
                                                         error:&error];
        if (error) {
            NSLog(@"error %@",error);
        }

        [_anAudioRecorder setDelegate:self];
        [_anAudioRecorder recordForDuration:60];
        UIImage *image=[UIImage imageNamed:@"stop-recording-control.png"];
        [recordButton setImage:image forState:UIControlStateNormal];
        [_playRecordedButton setEnabled:NO];
        [_progressView setHidden:NO];
        _timerProgress=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }else{
        [_anAudioRecorder stop];
        [_playRecordedButton setEnabled:YES];
        [_progressView setHidden:YES];
        UIImage *image=[UIImage imageNamed:@"start-recording-control.png"];
        [recordButton setImage:image forState:UIControlStateNormal];
        
    }
    
}
-(void)updateProgress{
    double table=_anAudioRecorder.currentTime;
    table=table/60.0;
    [_progressView setProgress:table];
    
   // CGFloat float=
    
}
- (IBAction)stopRecording:(id)sender {
    if (_anAudioRecorder) {
        if ([_anAudioRecorder isRecording]) {
            [_anAudioRecorder stop];

            [_recordAudioButton setEnabled:YES];
        }
    }
    if (_anAudioPlayer) {
        if ([_anAudioPlayer isPlaying]) {
            [_anAudioPlayer stop];

        }
    }
}

- (IBAction)playRecorded:(id)sender {
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //ima4
    NSString *appenLoc=[[NSString alloc]initWithFormat:@"%d/%d.ima4",iden,_pageNumber ];
 NSString *loc=[path stringByAppendingPathComponent:appenLoc];
    if ([[NSFileManager defaultManager]fileExistsAtPath:loc]) {
        if (!_anAudioPlayer) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),&audioRouteOverride);
            _anAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:loc] error:nil];
            [_anAudioPlayer setDelegate:self];
            [_anAudioPlayer setVolume:1.0];
            [_anAudioPlayer play];
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playRecordedButton setImage:image forState:UIControlStateNormal];
        }else if(![_anAudioPlayer isPlaying]){
            [_anAudioPlayer play];
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playRecordedButton setImage:image forState:UIControlStateNormal];
        }else {
            [_anAudioPlayer pause];
            UIImage *image=[UIImage imageNamed:@"play-control.png"];
            [_playRecordedButton setImage:image forState:UIControlStateNormal];
        }
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
 /*   if ([player isEqual:_playerDefault]) {
        if (_shouldAutoPlay) {
            _pageNumber++;
            [self loadPage];
        }
        _playerDefault=nil;
    UIImage *image=[UIImage imageNamed:@"pause-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    }*/
    
UIImage *image=[UIImage imageNamed:@"play-control.png"];
[_playRecordedButton setImage:image forState:UIControlStateNormal];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Error %@",error);
   // [_anAudioRecorder release];
   // _anAudioPlayer=nil;
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion==UIEventSubtypeMotionShake){
        [_webview stringByEvaluatingJavaScriptFromString:@"shakeActions()"];
        
        NSLog(@"motion shake");
    }
}
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 
    
}
@end
