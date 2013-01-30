//
//  ViewController.m
//  PassKit Demo
//
//  Created by jtang on 9/9/12.
//  Copyright (c) 2012 jtang. All rights reserved.
//

#import "ViewController.h"
#import "PassKit/PassKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _passLib = [[PKPassLibrary alloc] init];
    
    //check if pass library is available
    if (![PKPassLibrary isPassLibraryAvailable])
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass Library Error" message:@"The Pass Library is not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPassButtonPressed:(id)sender {
  
    //load StoreCard.pkpass from resource bundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"StoreCard" ofType:@"pkpass"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    
    //init a pass object with the data
    PKPass *pass = [[PKPass alloc] initWithData:data error:&error];

    
    //check if pass library contains this pass already
    if([_passLib containsPass:pass]) {
        
        //pass already exists in library, show an error message
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass Exists" message:@"The pass you are trying to add to Passbook is already present." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    } else {
        
        //present view controller to add the pass to the library
        PKAddPassesViewController *vc = [[PKAddPassesViewController alloc] initWithPass:pass];
        [vc setDelegate:(id)self];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)accessPassButtonPressed:(id)sender {
 
    NSArray * passArray = [_passLib passes];
    NSLog(@"number of passes in library are: %d",[passArray count]);
    
    _numberOfPasses.text = [NSString stringWithFormat:@"%d",[passArray count]];
    
    //if more tha one pass in library, just use the first one.
    if ([passArray count] > 0)
    {
        PKPass *onePass = [passArray objectAtIndex:0];
        
        //access general fieldnames
        _localizedName.text = [onePass localizedName];
        _organizationName.text = [onePass organizationName];
        
        //access a specific field name
        _rewardsBalance.text = [onePass localizedValueForFieldKey:@"rewards"];
    }
    else
    {
        //reset the screen
        _localizedName.text = @"";
        _organizationName.text = @"";
        _rewardsBalance.text = @"";
    }
}

- (IBAction)modifyPassButtonPressed:(id)sender {

    //load StoreCard2.pkpass from resource bundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"StoreCard2" ofType:@"pkpass"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    
    //init a pass object with the data
    PKPass *newPass = [[PKPass alloc] initWithData:data error:&error];
    //init a pass object with the data
    PKPass *oldPass = [_passLib passWithPassTypeIdentifier:@"pass.captechventures.blog" serialNumber:@"p69f2J"];
        
    //check if pass library contains this pass already
    if (oldPass)
    {
        //replace old pass with new pass
        [_passLib replacePassWithPass:newPass];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass has been replaced" message:@"The pass has been successfully replaced." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

    } else {
        //show an error message
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass does not exist" message:@"The pass you are trying to modify is not present." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}

- (IBAction)removePassButtonPressed:(id)sender {
   
    
    //init a pass object with the data
    PKPass *pass = [_passLib passWithPassTypeIdentifier:@"pass.captechventures.blog" serialNumber:@"p69f2J"];
    
    //check if pass library contains this pass already
    if (pass)
    {
        [_passLib removePass:pass];
        //pass already exists in library, show an error message
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass removed" message:@"The pass has been removed from the library." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        //pass already exists in library, show an error message
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Pass does not exist" message:@"The pass you are trying to remove is not present." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}
@end
