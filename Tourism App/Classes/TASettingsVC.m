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
	
	NSArray *accountObjects = [NSArray arrayWithObjects:@"Private photos", @"Default city", nil];
	NSArray *otherObjects = [NSArray arrayWithObjects:@"About", @"Contact support", nil];
	
	self.keys = [NSArray arrayWithObjects:@"Account", @"Other", nil];
	NSArray *objects = [NSArray arrayWithObjects:accountObjects, otherObjects, nil];
	
	self.menuDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:self.keys];
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
	
	// Set the selected City
	//[self setSelectedCity:city]; 
	
	// Set the city button's title to that of the City selected
	//[self.cityBtn setTitle:[city objectForKey:@"city"] forState:UIControlStateNormal];
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
		
	
	if ([listItem isEqualToString:@"Private photos"]){
		
		
	}
	
	else if ([listItem isEqualToString:@"Default city"]){
		
		TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
		//[citiesListVC setDelegate:self];
		
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



@end
