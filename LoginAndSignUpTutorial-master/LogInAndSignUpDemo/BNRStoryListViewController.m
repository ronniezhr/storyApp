//
//  BNRStoryListViewController.m
//  Storyteller
//
//  Created by Huirong Zhu on 7/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRStoryListViewController.h"
#import "BNRStory.h"
#import "BNRStoryDetailViewController.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "BNRStoryStore.h"
#import "BNRNewStoryViewController.h"

@interface BNRStoryListViewController ()

@property (nonatomic) NSMutableArray *currentStories;
@property (nonatomic) NSMutableArray *finishedStories;

@end

@implementation BNRStoryListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad:(BOOL)animated {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    if (![PFUser currentUser]) { // No user logged in
        // Customize the Log In View Controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.facebookPermissions = @[@"friends_about_me"];
        logInViewController.fields = PFLogInFieldsUsernameAndPassword |PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton;
        
        // Customize the Sign Up View Controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
        logInViewController.signUpController = signUpViewController;
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentStories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    NSArray *stories = [[BNRStoryStore sharedStore] allStories];
    BNRStory *story;
    if (stories.count > indexPath.row) {
        story = stories[indexPath.row];
    } else {
        story = [[BNRStoryStore sharedStore] createStory];
    }
    cell.textLabel.text = story.name;
    return cell;
    
   // PFQuery *query
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *stories = [[BNRStoryStore sharedStore] allStories];
    BNRStory *story = stories[indexPath.row];
    [self performSegueWithIdentifier:@"ExistingStory" sender:story];
}

- (NSMutableArray *)currentStories
{
    if (!_currentStories) {
        _currentStories = [NSMutableArray array];
    }
    return _currentStories;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewStory"]) {
        BNRStory *story = sender;
        [self.currentStories addObject:story];
        UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
        BNRNewStoryViewController *svc = (BNRNewStoryViewController *)[nc topViewController];
        svc.storyDetail = story;
    } else if ([segue.identifier isEqualToString:@"ExistingStory"]) {
        BNRStory *story = sender;
        if (story.newStory) {
            BNRStoryDetailViewController *svc = (BNRStoryDetailViewController *)segue.destinationViewController;
            svc.storyDetail = story;
            svc.existingStory = YES;
        } else {
            BNRStoryDetailViewController *svc = (BNRStoryDetailViewController *)segue.destinationViewController;
            svc.storyDetail = story;
            svc.existingStory = NO;
        }
    }
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed login view");
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self viewDidLoad:YES];
}


@end
