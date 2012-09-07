//
//  TAFriendsVC.m
//  Tourism App
//
//  Created by Richard Lee on 4/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAFriendsVC.h"
#import "TAUsersVC.h"

@interface TAFriendsVC ()

@end

@implementation TAFriendsVC

@synthesize friendsTable, tableContent;


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
    
	//self.tableContent = [NSArray arrayWithObjects:@"Find friends via Twitter", @"Find friends via FB", @"Invite friends", @"Search users", nil];
	
	self.tableContent = [NSArray arrayWithObjects:@"Invite friends", @"Search users", nil];

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
	
	self.tableContent = [NSArray arrayWithObjects:@"Find friends via Twitter", @"Find friends via FB", @"Invite friends", @"Search users", nil];
	
	// TWITTER
	if ([cellTitle isEqualToString:@"Find friends via Twitter"]) {
	
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeFindViaTwitter];
		
		[self.navigationController pushViewController:usersVC animated:YES];
		[usersVC release];
	}
	
	else if ([cellTitle isEqualToString:@"Search users"]) {
		
		TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
		[usersVC setUsersMode:UsersModeSearchUsers];
		
		[self.navigationController pushViewController:usersVC animated:YES];
		[usersVC release];
	}
}



@end
