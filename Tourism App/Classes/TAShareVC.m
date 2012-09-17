//
//  TAShareVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAShareVC.h"
#import "TAAppDelegate.h"
#import "SVProgressHUD.h"
#import "Tag.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "StringHelper.h"
#import "XMLFetcher.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TAUsersVC.h"
#import "MyMapAnnotation.h"
#import "TAPlacesVC.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#define SUBMIT_ALERT_TAG 9000
#define MAIN_CONTENT_HEIGHT 367

@interface TAShareVC ()

@end

@implementation TAShareVC

@synthesize photo, imageReferenceURL, selectedCity, tagBtn, captionField, map;
@synthesize currentLocation, selectedTag, cityLabel, recommendToUsernames, placeData, selectedAccountIdentifier;
@synthesize placeTitleLabel, placeAddressLabel, scrollView, twitterAccounts, savedAccountStore;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
		self.title = @"Share";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Tag button title alignment
	[self.tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	
	
	// Add submit button to the top nav bar
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"SUBMIT" style:UIBarButtonItemStyleDone target:self action:@selector(submitPhoto:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	[buttonItem release];
	
	
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 450.0)];
	
	
	
	// Determine the 'current location' being used for 
	// the photo being submitted. Either an imageReferenceURL has
	// been provided or the current location has been set by TACameraVC
	// Then trigger the Yahoo API call to get the associated City.
	[self configureCurrentLocation];
	
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.selectedCity = nil;
	self.currentLocation = nil;
	self.selectedTag = nil;
	self.recommendToUsernames = nil;
	self.placeData = nil;
	self.twitterAccounts = nil;
	
	[captionField release];
	self.captionField = nil;
	
	self.photo = nil; 
	self.imageReferenceURL = nil;
	
	[tagBtn release];
	self.tagBtn = nil;
	
	[cityLabel release];
	self.cityLabel = nil;
	
	[map release];
	self.map = nil;
	[placeTitleLabel release];
	self.placeTitleLabel = nil;
	
	[placeAddressLabel release];
	self.placeAddressLabel = nil;
	
	[scrollView release];
	self.scrollView = nil;
	
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[currentLocation release];
	[selectedTag release];
	[recommendToUsernames release];
	[placeData release];
	
	[selectedCity release];
	[photo release];
	[imageReferenceURL release];

	[captionField release];
	[tagBtn release];
	[cityLabel release];
	[map release];
	[placeTitleLabel release];
	[placeAddressLabel release];
	[scrollView release];
	[super dealloc];
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	/*
		Determine the title of the twitter account
		that was selected from the UIActionSheet
	*/
	
	if (buttonIndex != 0) {
		
		//NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
		NSLog(@"btnTitle:%i", buttonIndex);
		NSLog(@"retain count:%i", [self.twitterAccounts count]);
		
		
		// Grab the initial Twitter account to tweet from.
		ACAccount *twitterAccount = [self.twitterAccounts objectAtIndex:(buttonIndex-1)];
		
		self.selectedAccountIdentifier = twitterAccount.identifier;
		
		NSString *userID = [[twitterAccount accountProperties] objectForKey:@"user_id"];
		NSLog(@"ACC ID:%@", userID);
		
		[[self appDelegate] setTwitterUsername:twitterAccount.username];
		[[self appDelegate] setTwitterUserID:userID];
		[[self appDelegate] setTwitterAccountID:self.selectedAccountIdentifier];
		
		// Update the user's profile with the twitter user id
		[self initUpdateProfileAPI:userID];
	}
}


#pragma PlacesDelegate methods 

- (void)placeSelected:(NSMutableDictionary *)newPlaceData {

	self.placeData = newPlaceData;
	
	NSLog(@"RECEIVED PLACE DATA:%@", self.placeData);
	
	// Retrieve the lat/lng data from the dictionary and
	// update the map marker, and make the map focus on the new coord
	NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	CLLocationCoordinate2D newCoord;
	newCoord.latitude = [[locationData objectForKey:@"lat"] doubleValue];
	newCoord.longitude = [[locationData objectForKey:@"lng"] doubleValue];
	
	[self updateMap:newCoord];
	
	// Update the 'currentLocation' property to reflect the lat/lng values
	// that were part of the place that was selected
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoord.latitude longitude:newCoord.longitude];
	self.currentLocation = newLocation;
	[newLocation release];
	
	// Update place title and place address
	self.placeTitleLabel.text = [self.placeData objectForKey:@"name"];
	
	NSArray *locationKeys = [locationData allKeys];
	NSMutableString *formattedAddress = [NSMutableString string];
	
	if ([locationKeys containsObject:@"address"])
		[formattedAddress appendString:[locationData objectForKey:@"address"]];
	
	if ([locationKeys containsObject:@"city"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"city"]];
	
	if ([locationKeys containsObject:@"state"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"state"]];
	
	if ([locationKeys containsObject:@"postalCode"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"postalCode"]];
	
	self.placeAddressLabel.text = formattedAddress;
}


- (void)locationMapped:(NSMutableDictionary *)newPlaceData {
	
	self.placeData = newPlaceData;
	
	// Retrieve the lat/lng data from the dictionary and
	// update the map marker, and make the map focus on the new coord
	NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	CLLocationCoordinate2D newCoord;
	newCoord.latitude = [[locationData objectForKey:@"lat"] doubleValue];
	newCoord.longitude = [[locationData objectForKey:@"lng"] doubleValue];
	
	[self updateMap:newCoord];
	
	// Update the 'currentLocation' property to reflect the lat/lng values
	// that were part of the place that was selected
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoord.latitude longitude:newCoord.longitude];
	self.currentLocation = newLocation;
	[newLocation release];
	
	// Update place title and place address
	self.placeTitleLabel.text = [self.placeData objectForKey:@"name"];
	
	NSArray *locationKeys = [locationData allKeys];
	NSMutableString *formattedAddress = [NSMutableString string];
	
	if ([locationKeys containsObject:@"address"])
		[formattedAddress appendString:[locationData objectForKey:@"address"]];
	
	if ([locationKeys containsObject:@"city"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"city"]];
	
	if ([locationKeys containsObject:@"state"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"state"]];
	
	if ([locationKeys containsObject:@"postalCode"])
		[formattedAddress appendFormat:@" %@", [locationData objectForKey:@"postalCode"]];
	
	self.placeAddressLabel.text = formattedAddress;
}


#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;		
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	MKPinAnnotationView* pinView;
	
    if ([annotation isKindOfClass:[MyMapAnnotation class]]) {
		
		// try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        pinView = (MKPinAnnotationView *)
		[self.map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!pinView) {
			
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
			
			[pinView setUserInteractionEnabled:YES];
			[pinView setCanShowCallout:NO];
		}
	}
	
	return pinView;
}


#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if (submissionSuccess) [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Hide keyboard
	[self.captionField resignFirstResponder];
	
	return YES;
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	self.recommendToUsernames = usernames;
}


#pragma TagsDelegate

- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag]; 
	
	// Set the Tag button's title to that of the Location's
	[self.tagBtn setTitle:tag.title forState:UIControlStateNormal];
}


- (IBAction)submitPhoto:(id)sender {
	
	// Check that a Tag and a Location have been assigned
	if (self.selectedTag && self.selectedCity) {
		
		// Show loading animation
		[self showLoading];
		
		// Share with TWITTER
		[self initTwitterRequest];
		
		// Set local var
		submissionSuccess = NO;
				
		// Create the URL for this request
		NSString *methodName = [NSString stringWithString:@"Submit"];
		NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
		
		// Initialiase the URL Request
		NSMutableURLRequest *request = [self createSubmitRequest:url];
		
		// JSONFetcher
		submitFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													   receiver:self action:@selector(receivedSubmitResponse:)];
		[submitFetcher start];
	}
	
	else {
		
		NSString *message = @"Your image cannot be submitted until a city has been assigned and you have selected a tag.";
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}


// Example fetcher response handling
- (void)receivedSubmitResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"SUBMIT DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == submitFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			submissionSuccess = YES;
		}
		
		[jsonString release];
	}
	
	NSString *responseMessage;
	NSString *responseTitle = ((submissionSuccess) ? @"Success!" : @"Sorry!");
	
	// If the submission was successful
	if (submissionSuccess) responseMessage = @"Your photo was successfully submitted.";
	else responseMessage = @"There was an error submitting your photo.";
	
	
	// Show pop up for submission result
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:responseTitle
														message:responseMessage
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView setTag:SUBMIT_ALERT_TAG];
	[alertView show];
	[alertView release];
	
	
	// Create Image object and store
	if (submissionSuccess) {
		
		// Pop to root view controller (photo picker/camera)
		//[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
	// Hide loading animation
	[self hideLoading];
	
	// Clean up
	[submitFetcher release];
	submitFetcher = nil;
    
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (NSMutableURLRequest *)createSubmitRequest:(NSURL *)requestURL {
	
	NSMutableURLRequest *request =(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];	
	
	/*
	 Set Header and content type of your request.
	 */
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n",boundary];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	
	/*
	 now lets create the body of the request.
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	NSMutableDictionary *bodyData = [NSMutableDictionary dictionary];
	
	// Caption
	[bodyData setObject:self.captionField.text forKey:@"caption"];
	
	// Username
	NSString *username = [[self appDelegate] loggedInUsername];
	[bodyData setObject:username forKey:@"username"];
	
	// Session token
	NSString *token = [[self appDelegate] sessionToken];
	[bodyData setObject:token forKey:@"token"];
	
	// Latitude
	NSString *latString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
	[bodyData setObject:latString forKey:@"latitude"];
	
	// Longitude
	NSString *lonString = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
	[bodyData setObject:lonString forKey:@"longitude"];
	
	
	// RECOMMEND?
	if ([self.recommendToUsernames count] > 0) {
		
		NSString *recType = [NSString stringWithFormat:@"%i", 0];
		[bodyData setObject:recType forKey:@"rectype"];
		
		NSString *usernames = [NSString stringWithFormat:@"%@", [self.recommendToUsernames componentsJoinedByString:@","]];
		[bodyData setObject:usernames forKey:@"rec_usernames"];
	}
	
	
	if (self.placeData) {
	
		NSDictionary *locationData = [self.placeData objectForKey:@"location"];
	
		NSString *placeTitle = [self.placeData objectForKey:@"name"];
		[bodyData setObject:placeTitle forKey:@"place_title"];
		
		NSString *address = [locationData objectForKey:@"address"];
		[bodyData setObject:address forKey:@"place_address"];
		
		NSString *city = [locationData objectForKey:@"city"];
		[bodyData setObject:city forKey:@"place_city"];
		
		NSString *state = [locationData objectForKey:@"state"];
		[bodyData setObject:state forKey:@"place_state"];
		
		NSString *country = [locationData objectForKey:@"country"];
		[bodyData setObject:country forKey:@"place_country"];
		
		NSString *postalCode = [locationData objectForKey:@"postalCode"];
		[bodyData setObject:postalCode forKey:@"place_postcode"];
		
		NSString *verified = [self.placeData objectForKey:@"verified"];
		[bodyData setObject:verified forKey:@"verified"];
	}
	
	
	// Tag
	NSString *tagString = [NSString stringWithFormat:@"%i", [self.selectedTag.tagID intValue]];
	[bodyData setObject:tagString forKey:@"tag"];
	
	// City
	NSString *cityString = [NSString stringWithFormat:@"%@", self.selectedCity];
	[bodyData setObject:cityString forKey:@"city"];
	
	// Type
	[bodyData setObject:@"image" forKey:@"type"];
	
	
	// Loop through the keys of the dictionary of body data
	// and add to the body of the request with the data properly formatted
	NSArray *keys = [bodyData allKeys];
	
	for (int i = 0; i < [keys count]; i++) {
		
		NSString *key = [keys objectAtIndex:i];
		NSString *val = [bodyData objectForKey:key];
	
		NSString *formattedStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, val];
	
		[body appendData:[formattedStr dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
	} 
	
	
	// IMAGE
	NSNumber *randomNum = [self generateRandomNumberWithMax:100000];
	NSString *imageFilename = [NSString stringWithFormat:@"%i", [randomNum intValue]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", imageFilename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:UIImageJPEGRepresentation(self.photo, 0.7)]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"]; 
	
	return request;
}


/* 
	selectTagButtonTapped();
	This function will take the user to a new screen
	where he/she can select a 'tag' for the image about
	to be published. 
 */
- (IBAction)selectTagButtonTapped:(id)sender {
	
	TASimpleListVC *tagListVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[tagListVC setListMode:ListModeTags];
	[tagListVC setManagedObjectContext:[self appDelegate].managedObjectContext];
	[tagListVC setDelegate:self];
	
	[self.navigationController pushViewController:tagListVC animated:YES];
	[tagListVC release];
}


- (IBAction)shareButtonTapped:(id)sender {

	/* 
		Retrieve the stored Twitter accounts 
		on this phone and detect whether any 
		of them have had access granted to this user
		to be used 
	*/
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	self.savedAccountStore = accountStore;
	[accountStore release];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [self.savedAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	self.twitterAccounts = [NSMutableArray array];
	
	// Request access from the user to use their Twitter accounts.
	[self.savedAccountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
	
			// Get the list of Twitter accounts.
			//NSArray *arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
			self.twitterAccounts = [self.savedAccountStore accountsWithAccountType:accountType];
			
			if ([self.twitterAccounts count] > 0) {
			
				//[self presentTwitterAccountsSheet];
				
				[self performSelectorOnMainThread:@selector(presentTwitterAccountsSheet:) withObject:self.twitterAccounts waitUntilDone:NO];
				
				//ACAccount *twitterAccount = [arrayOfAccounts objectAtIndex:2];
				
			}
		}	
	}];
}


- (void)presentTwitterAccountsSheet:(NSArray *) accountsArray {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:nil];
	
	for (ACAccount *account in self.twitterAccounts) {
		
		NSString *accountTitle = account.accountDescription;
		[actionSheet addButtonWithTitle:accountTitle];
	}
	
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    [actionSheet release];
}


- (NSNumber *)generateRandomNumberWithMax:(int)maxInt {
	
	int value = (arc4random() % maxInt) + 1;
	NSNumber *randomNum = [[NSNumber alloc] initWithInt:value];
	
	return [randomNum autorelease];
}


- (void)retrieveLocationData {
	
	// Create JSON call to retrieve dummy City values
	NSString *methodName = @"geocode";
	NSString *yahooURL = @"http://where.yahooapis.com/";
	NSString *yahooAPIKey = @"UvRWaq30";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@?q=%f,%f&gflags=R&appid=%@", yahooURL, methodName, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, yahooAPIKey];
	NSLog(@"YAHOO URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(HTTPFetcher *)aFetcher {
    
    XMLFetcher *theXMLFetcher = (XMLFetcher *)aFetcher;
    NSAssert(aFetcher == cityFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	//NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	// IF STATUS CODE WAS OKAY (200)
	if ([theXMLFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([theXMLFetcher.data length] > 0) && ([theXMLFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [theXMLFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) { 
							
							NSLog(@"SELECTED LOCATION:%@", [childNode contentString]);
							
							self.selectedCity = [childNode contentString];
						}
					}
				}
			}
		}
	}
	
	if (requestSuccess && !errorDected) {
		
		[self.cityLabel setText:self.selectedCity];
	}
	else [self.cityLabel setText:@"Could not assign city."];
	
    
    [cityFetcher release];
    cityFetcher = nil;	
	
}


- (IBAction)recommendButtonTapped:(id)sender {
	
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
	[usersVC release];
}


- (void)configureCurrentLocation {

	if (self.imageReferenceURL != nil) {
		
		ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
		__block double latitude;
		__block double longitude;
		
		NSLog(@"referenceURL:%@", self.imageReferenceURL);
		
		[assetslibrary assetForURL:self.imageReferenceURL resultBlock:^(ALAsset *asset) {
			
			CLLocation *loc = ((CLLocation*)[asset valueForProperty:ALAssetPropertyLocation]);
			CLLocationCoordinate2D c = loc.coordinate;
			longitude = (double)c.longitude;
			latitude  = (double)c.latitude;
			
			// Make lat/lon easier to reference
			double lat = latitude;
			double lon = longitude;
			
			CLLocation *newCurrentLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			self.currentLocation = newCurrentLocation;
			[newCurrentLocation release];
			
			NSLog(@"RETRIEVE LOCATION DATA");
			[self retrieveLocationData];
			
			// Place the current location 
			// coordiantes on the map view
			[self initSingleLocation];
			
		} failureBlock:^(NSError *error) {
			
			NSLog(@"error:%@", error);
			
			NSString *errorMessage = @"Could not assign city.";
			[self.cityLabel setText:errorMessage];
			
			NSString *message = @"There was an error retrieving the location of the image. Please make sure location services are enabled for this app in your phone's Settings";
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			
		}];
		
		[assetslibrary release];
	}
	
	else {
		
		NSLog(@"RETRIEVE LOCATION DATA NOW");
		[self retrieveLocationData];
		
		// Place the current location 
		// coordiantes on the map view
		[self initSingleLocation];
	}
}


- (void)initSingleLocation {
	
	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = self.currentLocation.coordinate.latitude;
	coordLocation.longitude = self.currentLocation.coordinate.longitude;
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Photo location";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
	[self.map addAnnotation:mapAnnotation];
	[mapAnnotation release];
}


- (IBAction)editPlaceButtonTapped:(id)sender {
	
	NSNumber *lat = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
	NSNumber *lng = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];

	TAPlacesVC *placesVC = [[TAPlacesVC alloc] initWithNibName:@"TAPlacesVC" bundle:nil];
	[placesVC setLatitude:lat];
	[placesVC setLongitude:lng];
	[placesVC setDelegate:self];
	
	[self.navigationController pushViewController:placesVC animated:YES];
	[placesVC release];
}


- (void)updateMap:(CLLocationCoordinate2D)newCoord {

	// Update the map view 
	// Retrieve the lat/lng data from the dictionary
	// Then retrieve the annotation (map marker) from the map
	// and udate it's coordinate property
	NSArray *annotations = [self.map annotations];
	
	MyMapAnnotation *annotation = (MyMapAnnotation *)[annotations lastObject];
	[annotation setCoordinate:newCoord];
	
	MKCoordinateRegion region = [self.map region];
	region.center = newCoord;
	
	[self.map setRegion:region animated:TRUE];
}


- (void)initTwitterRequest {
	
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [self.savedAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[self.savedAccountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			
			// Get the list of Twitter accounts.
			ACAccount *account = [self.savedAccountStore accountWithIdentifier:self.selectedAccountIdentifier];
			
			if (account) {
				
				// Build a twitter request
				TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST] autorelease];
				
				//add text
				[postRequest addMultiPartData:[@"Check out this photo I took!" dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
				
				//add image
				[postRequest addMultiPartData:UIImageJPEGRepresentation(self.photo, 0.7) withName:@"media" type:@"multipart/form-data"];
				
				NSData *val = [[NSString stringWithFormat:@"true"] dataUsingEncoding:NSUTF8StringEncoding];
				[postRequest addMultiPartData:val withName:@"display_coordinates" type:@"multipart/form-data"];
				
				[postRequest addMultiPartData:[[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding] withName:@"lat" type:@"multipart/form-data"];
				
				[postRequest addMultiPartData:[[NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding] withName:@"long" type:@"multipart/form-data"];
				
				
				// Set the account used to post the tweet.
				[postRequest setAccount:account];
				
				// Block handler to manage the response
				[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					
					if ([urlResponse statusCode] == 200) {
						
						// The response from Twitter is in JSON format
						// Move the response into a dictionary and print
						NSError *error;        
						NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
						NSLog(@"Twitter response: %@", dict);                           
					}
					
					else
						NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
				}];
			}
		}	
	}];

	
}


- (void)initUpdateProfileAPI:(NSString *)twt_userid {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&twt_userid=%@&token=%@", [self appDelegate].loggedInUsername, twt_userid, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"UpdateProfile"];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_ADDRESS, methodName];
	
	// Print the URL to the console
	NSLog(@"URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	updateProfileFetcher = [[JSONFetcher alloc] initWithURLRequest:request
														  receiver:self action:@selector(receivedUpdateProfileResponse:)];
	[updateProfileFetcher start];
	
	////////////////////////////////////////////////////////////////////////////////
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == updateProfileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
	}
	
	[updateProfileFetcher release];
	updateProfileFetcher = nil;
}


- (void)verifyTwitterCredentials:(ACAccount *)twitterAccount {

	//NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"richC2", @"username", @"chevy78!rfl", @"password", nil];
	
	// Send off a account/verify_credentials request
	TWRequest *verifyRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"] parameters:nil requestMethod:TWRequestMethodGET] autorelease];
	
	// Set the account used to post the tweet.
	[verifyRequest setAccount:twitterAccount];
	
	// Block handler to manage the response
	[verifyRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if ([urlResponse statusCode] == 200) {
			
			// The response from Twitter is in JSON format
			// Move the response into a dictionary and print
			NSError *error;        
			NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
			NSLog(@"Twitter response: %@", dict);
			
		}
		
		else
			NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
	}];
}


@end
