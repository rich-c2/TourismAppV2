//
//  TASettingsVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TASettingsVC.h"

@interface TASettingsVC ()

@end

@implementation TASettingsVC

@synthesize settingsTable, listItems;


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
    
	self.listItems = [NSArray arrayWithObjects:@"Private photos", @"Default city", @"About", @"Contact support", nil];
}

- (void)viewDidUnload {
	
	self.listItems = nil;
	
    [settingsTable release];
    self.settingsTable = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[listItems release];
    [settingsTable release];
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
	
	NSString *listItem = [self.listItems objectAtIndex:[indexPath row]];
	
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *listItem = [self.listItems objectAtIndex:[indexPath row]];
	
	[NSArray arrayWithObjects:@"Private photos", @"Default city", @"About", @"Contact support", nil];
	
	if ([listItem isEqualToString:@"Private photos"]){
		
	}
	
	else if ([listItem isEqualToString:@"Default city"]){
		
	}
	
	else if ([listItem isEqualToString:@"Default city"]){
		
	}
	
	else if ([listItem isEqualToString:@"About"]){
		
	}
	
	else if ([listItem isEqualToString:@"Contact support"]){
		
	}
}



@end
