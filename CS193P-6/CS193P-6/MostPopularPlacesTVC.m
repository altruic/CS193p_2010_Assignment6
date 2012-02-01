//
//  PlacesTableViewController.m
//  CS193P-5
//
//  Created by Ed Sibbald on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MostPopularPlacesTVC.h"

#import "FlickrFetcher.h"
#import "DictPlace.h"
#import "DictPhoto.h"
#import "MostPopularPhotosTVC.h"


@implementation MostPopularPlacesTVC

- (void)reloadPlaces
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSArray *topPlaces = [FlickrFetcher topPlaces];
	//NSLog(@"topPlaces returned: %@", topPlaces);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	NSMutableArray *unsortedPlaces = [NSMutableArray arrayWithCapacity:[topPlaces count]];
	
	for (id obj in topPlaces) {
		if (![obj isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Non-dictionary returned from +topPlaces");
			continue;
		}
		NSDictionary *topPlace = (NSDictionary *)obj;
		DictPlace *place = [[DictPlace alloc] initWithDictionary:topPlace];
		if (place)
			[unsortedPlaces addObject:place];
		[place release];
	}

	NSMutableArray *sortDescriptors = [NSMutableArray array];
	[sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	[sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]];
	
	[_places release];
	_places = [[unsortedPlaces sortedArrayUsingDescriptors:sortDescriptors] retain];
}


- (void)setup
{
	self.title = @"Popular Places";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostViewed tag:0] autorelease];
	[self reloadPlaces];
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		[self setup];
		_context = context;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)refreshButtonTapped
{
	[self reloadPlaces];
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				   target:self
																				   action:@selector(refreshButtonTapped)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{ return YES; }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (section != 0)
		return 0;
    return [_places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellWithDetailIdentifier = @"CellWithDetail";

    DictPlace *place = indexPath.section == 0 ? (DictPlace *)[_places objectAtIndex:indexPath.row] : nil;
	BOOL hasDetail = place.desc && [place.desc length] > 0;

    NSString *currentCellIdentifier = hasDetail ? CellWithDetailIdentifier : CellIdentifier;
	UITableViewCellStyle currentCellStyle = hasDetail ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:currentCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:currentCellStyle reuseIdentifier:currentCellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = place.name;
	cell.detailTextLabel.text = place.desc;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 0 || indexPath.row >= [_places count]) {
		NSLog(@"Invalid selected indexPath: %@", indexPath);
		return;
	}
	
	DictPlace *selectedPlace = [_places objectAtIndex:indexPath.row];
	if (!selectedPlace) {
		NSLog(@"Nil place at position: %i", indexPath.row);
		return;
	}
	
	MostPopularPhotosTVC *photosTVC = [[MostPopularPhotosTVC alloc] initWithPlace:selectedPlace
															  manageObjectContext:_context];
	[self.navigationController pushViewController:photosTVC animated:YES];
	[photosTVC release];
}

@end
