//
//  TASimpleListVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TASimpleListVC.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "TAProfileVC.h"
#import "TAAppDelegate.h"
#import "Tag.h"

@interface TASimpleListVC ()

@end

@implementation TASimpleListVC

@synthesize listItems, imageCode, listMode, listTable, managedObjectContext, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
	
	self.imageCode = nil;
	self.listItems = nil;
	self.managedObjectContext = nil;
	
	[listTable release];
	listTable = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	if (!usersLoaded && !loading) {
		
		loading = YES;
		
		// Show loading animation
		[self showLoading];
		
		if (self.listMode == ListModeLovedBy) 
			[self initLovedByAPI];
		else if (self.listMode == ListModeTags) 
			[self fetchTags];
	}
}


- (void)dealloc {
	
	[managedObjectContext release];
	[imageCode release];
	[listItems release];
	[listTable release];
	[super dealloc];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.listItems count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellText;
	    
	if (self.listMode == ListModeLovedBy) {
		
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *item = [self.listItems objectAtIndex:[indexPath row]];
		
		cellText = [item objectForKey:@"username"];
	}
	
	// Tag mode - retrieve the Tag object from the array
	else if (self.listMode == ListModeTags) {
		
		Tag *tag = [self.listItems objectAtIndex:[indexPath row]];
		
		cellText = tag.title;
	}
		
	cell.textLabel.text = cellText;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// If we're in 'Tag mode'
	if (self.listMode == ListModeTags) {
	
		Tag *tag = [self.listItems objectAtIndex:[indexPath row]];
	
		// Pass selected tag back to the delegate
		[self.delegate tagSelected:tag];
		
		// Go back to the previous screen
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	else if (self.listMode == ListModeLovedBy) {
	
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *user = [self.listItems objectAtIndex:[indexPath row]];
		
		TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
		[profileVC setUsername:[user objectForKey:@"username"]];
		
		[self.navigationController pushViewController:profileVC animated:YES];
		[profileVC release];
			
	}
}


#pragma MY-METHODS

- (void)fetchTags {
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.listItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	[self hideLoading];
}


- (void)initLovedByAPI {
	
	NSString *postString = [NSString stringWithFormat:@"code=%@", self.imageCode];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"LovedBy"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	fetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedLovedByResponse:)];
	[fetcher start];
}


// Example fetcher response handling
- (void)receivedLovedByResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	NSLog(@"PRINTING LOVED BY:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
		// We've finished loading the artists
		usersLoaded = YES;
		
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newUsers = (NSMutableArray *)[results objectForKey:@"users"];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newUsers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		[alphaDesc release];
		
		self.listItems = newUsers;
		
		//NSLog(@"listItems:%@", self.listItems);
		
		// clean up
		[jsonString release];
    }
	
	// Reload table
	[self.listTable reloadData];
	
	[self hideLoading];
    
    [fetcher release];
    fetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}

@end
