//
//  FoodViewController.m
//  Grocer
//
//  Created by Sherród Faulks on 6/11/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import "FoodViewController.h"
#import "GrocerAppDelegate.h"
#import "FMResultSet.h"

@implementation FoodViewController

- (id)initWithFoodName:(FoodName *)newFoodName {
    self = [super initWithNibName:@"FoodViewController" bundle:nil];
    if (self) {
        food = [newFoodName retain];
        
        db = ((GrocerAppDelegate *)[UIApplication sharedApplication].delegate).db;
        
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popViewController:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipe];
        
        FMResultSet *results = [db executeQuery:[self sqlSelect:@"taste,alternateNames"]];
        [results next];
        taste = [results stringForColumn:@"taste"];
        NSString *sqlAlternateNames = [results stringForColumn:@"alternateNames"];
        NSArray *alternateNames = [sqlAlternateNames length] > 0 ? [sqlAlternateNames componentsSeparatedByString:@","] : [NSArray new];
        //NSLog(@"%d alternate names", [alternateNames count]);
        [results close];
        
        if ([alternateNames count] > 0) {
            if ([food hasGeneralName]) {
                NSMutableArray *fullAlternateNames = [[NSMutableArray alloc] initWithCapacity:[alternateNames count]];
                for (NSString *alternateSpecific in alternateNames) {
                    [fullAlternateNames addObject:[NSString stringWithFormat:@"%@ %@", alternateSpecific, food.generalName]];
                }
                aka = [fullAlternateNames componentsJoinedByString:@"/"];
                [fullAlternateNames release];
            } else {
                aka = [alternateNames componentsJoinedByString:@"/"];
            }
        } else {
            aka = nil;
        }
    }
    return self;
}

- (NSString *) sqlSelect:(NSString *)select {
    return [NSString stringWithFormat:@"SELECT %@ FROM foods WHERE id = %d", select, food.sqlId];
}

- (void)dealloc
{
    [swipe release];
    [food release];
    [super dealloc];
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
    UILabel *label = (UILabel *)[self.view viewWithTag:1];
    label.text = food.name;
    label.textColor = [UIColor colorWithWhite:0.15 alpha:1];
    //label.shadowColor = [UIColor colorWithWhite:0.72 alpha:1];
    //label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont fontWithName:@"MoanHand" size:45];
    
    UITextView *tasteTextView = (UITextView *)[self.view viewWithTag:2];
    tasteTextView.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    tasteTextView.font = [UIFont fontWithName:@"Sketchetik" size:24];
    if (aka) {
        tasteTextView.text = [NSString stringWithFormat:@"(aka %@) %@", aka, taste];
    } else {
        tasteTextView.text = taste;
    }
    
    UIImageView *foodImage = (UIImageView *)[self.view viewWithTag:3];
    foodImage.image = [[UIImage imageNamed:food.name] autorelease];
}

/*- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}*/

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (IBAction)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userDidSwipe {
    [self popViewController:self];
}
@end
