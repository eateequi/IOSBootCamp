//
//  MapViewController.m
//  DataBasedApp
//
//  Created by James Eberhardt on 12-03-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController
@synthesize mapView, data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.data = [DataModel getInstance];
    
    MKCoordinateRegion region;
	region.center=[(City*)[self.data.cities objectAtIndex:self.data.selectedCity] location];
	
	//Set Zoom level using Span
	MKCoordinateSpan span;
	span.latitudeDelta=0.0;
	span.longitudeDelta=0.1;
	region.span=span;
	
	[(MKMapView*)self.mapView setRegion:region animated:TRUE];
    
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
