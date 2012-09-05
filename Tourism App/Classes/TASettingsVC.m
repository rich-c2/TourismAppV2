//
//  TASettingsVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TASettingsVC.h"
#import "TACitiesListVC.h"
#import <MessageUI/MessageUI.h>
#import "TAAppDelegate.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "EditProfileVC.h"

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TASettingsVC ()

@end

@implementation TASettingsVC

@synthesize settingsTable, menuDictionary, keys;


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
	
	NSArray *accountObjects = [NSArray arrayWithObjects:@"Log out", @"Private photos", @"Edit profile", nil];
	NSArray *otherObjects = [NSArray arrayWithObjects:@"About", @"Contact support", nil];
	NSArray *cityObjects = [NSArray arrayWithObjects:[self getUsersDefaultCity], nil];
	
	self.keys = [NSArray arrayWithObjects:@"Account", @"Default City", @"Other", nil];
	NSArray *objects = [NSArray arrayWithObjects:accountObjects, cityObjects, otherObjects, nil];
	
	self.menuDictionary = [NSMutableDictionary dictionaryWithObjects:objects forKeys:self.keys];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.menuDictionary = nil;
	self.keys = nil;
	
    [settingsTable release];
    self.settingsTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[keys release];
	[menuDictionary release];
    [settingsTable release];
    [super dealloc];
}


#pragma CitiesDelegate

- (void)locationSelected:(NSDictionary *)city {
	
	[self showLoading];
	
	NSString *newCity = [city objectForKey:@"city"];
	
	[self initUpdateProfileAPI:newCity];
	
	// Replace the default city value in the menuDictionary
	NSArray *newCityObjects = [NSArray arrayWithObjects:newCity, nil];
	[self.menuDictionary setValue:newCityObjects forKey:@"Default City"];
	
	[self.settingsTable reloadData];
	
	// A default city has just been selected. Store it.
	[[NSUserDefaults standardUserDefaults] setObject:newCity forKey:kUserDefaultCityKey];
}


#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    
    // Notifies users about errors associated with the interface
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		
    return [self.keys count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSArray *listData =[self.menuDictionary objectForKey:[self.keys objectAtIndex:section]];
	
    return [listData count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *listData =[self.menuDictionary objectForKey:[self.keys objectAtIndex:[indexPath section]]]; 
	NSString *listItem = [listData objectAtIndex:[indexPath row]];
	
	cell.textLabel.text = listItem;
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	return [self.keys objectAtIndex:section];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *listData =[self.menuDictionary objectForKey:[self.keys objectAtIndex:[indexPath section]]]; 
	NSString *listItem = [listData objectAtIndex:[indexPath row]];
		
	NSString *key = [self.keys objectAtIndex:[indexPath section]];
	
	
	
	// DO LOG OUTT!!!!!!!!
	if ([listItem isEqualToString:@"Log out"]){
		
		// Log the user out
		[self logout];
	}
	
	else if ([listItem isEqualToString:@"Private photos"]){
		
		
	}

	
	else if ([listItem isEqualToString:@"Edit profile"]){
		
		EditProfileVC *editProfileVC = [[EditProfileVC alloc] initWithNibName:@"EditProfileVC" bundle:nil];
		
		[self.navigationController pushViewController:editProfileVC animated:YES];
		[editProfileVC release];
	}
	
	else if ([key isEqualToString:@"Default City"]){
		
		TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
		[citiesListVC setDelegate:self];
		
		[self.navigationController pushViewController:citiesListVC animated:YES];
		[citiesListVC release];
	}
	
	else if ([listItem isEqualToString:@"About"]){
		
		/*
		TAAboutVC *aboutVC = [[TAAboutVC alloc] initWithNibName:@"TAAboutVC" bundle:nil];
		
		[self.navigationController pushViewController:aboutVC animated:YES];
		[aboutVC release];
		*/
	}
	
	else if ([listItem isEqualToString:@"Contact support"]){
		
		// Email message here
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		// SUBJECT
		[picker setSubject:@"RE: Tourism App"];
		
		// TO ADDRESS...
		NSArray *recipients = [[NSArray alloc] initWithObjects:@"hello@c2.net.au", nil];
		[picker setToRecipients:recipients];
		[recipients release];
		
		// BODY TEXT
		NSString *bodyContent = @"I was using the Tourism App...";
		NSString *emailBody = [NSString stringWithFormat:@"%@\n\n", bodyContent];
		[picker setMessageBody:emailBody isHTML:NO];
		
		// SHOW INTERFACE
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
}
							
							
- (NSString *)getUsersDefaultCity {
	
	// In time this should be a property that will be saved in NSUserDefaults.
	NSString *defaultCity = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCityKey];
	
	return defaultCity;
}



- (void)initUpdateProfileAPI:(NSString *)newCity {
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@&token=%@", [self appDelegate].loggedInUsername, newCity, [[self appDelegate] sessionToken]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Login"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
    profileFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedUpdateProfileResponse:)];
    [profileFetcher start];
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		/*NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		 
		 // Create a dictionary from the JSON string
		 NSDictionary *results = [jsonString JSONValue];
		 
		 // Build an array from the dictionary for easy access to each entry
		 NSDictionary *newUserData = [results objectForKey:@"user"];
		 
		[jsonString release];*/
	}
	
	// Hide loading view
	[self hideLoading];
	
	[profileFetcher release];
	profileFetcher = nil;
    
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


#pragma mark - Public Methods

- (void)logout {
	
    [[self appDelegate].loginVC logout];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


@end
