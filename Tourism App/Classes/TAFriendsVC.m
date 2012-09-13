//
//  TAFriendsVC.m
//  Tourism App
//
//  Created by Richard Lee on 4/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAFriendsVC.h"
#import "TAUsersVC.h"
#import "TAAppDelegate.h"

@interface TAFriendsVC ()

@end

@implementation TAFriendsVC

@synthesize friendsTable, tableContent;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        self.title = @"Find friends";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	//self.tableContent = [NSArray arrayWithObjects:@"Find friends via Twitter", @"Find friends via FB", @"Invite friends", @"Search users", nil];
	
	self.tableContent = [NSArray arrayWithObjects:@"From my contacts list", @"Twitter friends", @"Search users", nil];

}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.tableContent = nil;
	
    [friendsTable release];
    friendsTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[tableContent release];
    [friendsTable release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    
    return [self.tableContent count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[self configureCell:cell atIndexPath:indexPath tableView:tableView];
	
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
	
	// Retrieve City from cities array
	NSString *cellTitle = [self.tableContent objectAtIndex:[indexPath row]]; 
	
	// Set the text of the cell
	cell.textLabel.text = cellTitle;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellTitle = [self.tableContent objectAtIndex:[indexPath row]];
	
	// CONTACTS LIST
	if ([cellTitle isEqualToString:@"From my contacts list"]) {
	
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaContacts];
		[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
		
		[self.navigationController pushViewController:usersVC animated:YES];
		[usersVC release];
	}
	
	if ([cellTitle isEqualToString:@"Twitter friends"]) { 
	
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaTwitter];
		
		[self.navigationController pushViewController:usersVC animated:YES];
		[usersVC release];
	}
	
	// SEARCH USERS
	else if ([cellTitle isEqualToString:@"Search users"]) {
		
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeSearchUsers];
		
		[self.navigationController pushViewController:usersVC animated:YES];
		[usersVC release];
	}
}



@end
