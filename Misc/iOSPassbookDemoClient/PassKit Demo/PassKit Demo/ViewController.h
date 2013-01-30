//
//  ViewController.h
//  PassKit Demo
//
//  Created by jtang on 9/9/12.
//  Copyright (c) 2012 jtang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassKit/PassKit.h"

@interface ViewController : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *numberOfPasses;
@property (weak, nonatomic) IBOutlet UILabel *localizedName;
@property (weak, nonatomic) IBOutlet UILabel *organizationName;
@property (weak, nonatomic) IBOutlet UILabel *rewardsBalance;
@property (strong, nonatomic) PKPassLibrary *passLib;

- (IBAction)addPassButtonPressed:(id)sender;
- (IBAction)accessPassButtonPressed:(id)sender;
- (IBAction)modifyPassButtonPressed:(id)sender;
- (IBAction)removePassButtonPressed:(id)sender;

@end
