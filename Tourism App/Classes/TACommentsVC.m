//
//  TACommentsVC.m
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACommentsVC.h"
#import "TAAppDelegate.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "AsyncCell.h"

@interface TACommentsVC ()

@end

@implementation TACommentsVC

@synthesize comments, commentsTable, imageCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
}



#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.imageCode = nil;
	self.comments = nil;
	
    [commentsTable release];
    self.commentsTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[imageCode release];
	[comments release]; 
    [commentsTable release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	if (!loading && !commentsLoaded) {
	
		loading = YES;
		
		[self initCommentsAPI];
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.comments count];
}


- (void)configureCell:(AsyncCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *comment = [self.comments objectAtIndex:[indexPath row]];
	
	/*NSString *username = [user objectForKey:@"username"];
	NSString *name = [user objectForKey:@"name"];
	NSString *avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [user objectForKey:@"avatar"]];
	
	[cell updateCellWithUsername:username withName:name imageURL:avatarURL];*/
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	AsyncCell *cell = (AsyncCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[AsyncCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	/*NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
	
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:[user objectForKey:@"username"]];
	//[profileVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:profileVC animated:YES];
	[profileVC release];*/
}


#pragma MY-METHODS

- (void)initCommentsAPI {

	NSString *postString = [NSString stringWithFormat:@"code=%@", self.imageCode];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Comments"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	commentsFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedCommentsResponse:)];
	[commentsFetcher start];
}


// Example fetcher response handling
- (void)receivedCommentsResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == commentsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;

	//NSLog(@"PRINTING COMMENTS DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// We've finished loading the artists
		commentsLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.comments = [results objectForKey:@"comments"];
    }
	
	//[self.commentField setText:@""];
	
	// Retrieve tracks from DB
	//[self fetchCommentsFromCoreData];
	
	// Make the keyboard appear straight away
	//[self.commentField becomeFirstResponder];
	
	[self hideLoading];
    
    [commentsFetcher release];
    commentsFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}





@end
