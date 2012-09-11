//
//  TAUsersVC.h
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

typedef enum  {
	UsersModeFollowing = 0,
	UsersModeFollowers = 1,
	UsersModeRecommendTo = 2,
	UsersModeFindViaContacts = 3,
	UsersModeFindViaFB = 4,
	UsersModeFindViaTwitter = 5, 
	UsersModeSearchUsers = 6
} UsersMode;

@class JSONFetcher;
@class AsyncCell;

@protocol RecommendsDelegate

- (void)recommendToUsernames:(NSMutableArray *)usernames;

@end

@interface TAUsersVC : UIViewController <UITableViewDelegate, UITableViewDataSource, ABPeoplePickerNavigationControllerDelegate> {

	id <RecommendsDelegate> delegate;
	
	IBOutlet UISearchBar *searchField;
	
	UsersMode usersMode;
	
	NSString *navigationTitle;
	
	NSManagedObjectContext *managedObjectContext;
	UITableView *usersTable;
	NSString *selectedUsername;
	NSArray *users;

	JSONFetcher *usersFetcher;
	NSInteger page;
	NSInteger batchSize;

	BOOL usersLoaded;
	BOOL loading;
}

@property (nonatomic, retain) id <RecommendsDelegate> delegate;

@property (nonatomic, retain) IBOutlet UISearchBar *searchField;

@property UsersMode usersMode;

@property (nonatomic, retain) NSString *navigationTitle;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView *usersTable;
@property (nonatomic, retain) NSString *selectedUsername;
@property (nonatomic, retain) NSArray *users;

- (void)configureCell:(AsyncCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)initFollowingAPI;

@end
