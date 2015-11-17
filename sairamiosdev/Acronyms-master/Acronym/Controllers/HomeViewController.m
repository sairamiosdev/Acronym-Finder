//
//  HomeViewController.m
//  Acronym
//
//  Created by Sairam  on 11/16/15.
 


#import "HomeViewController.h"
#import "AIConstants.h"
#import "AINetworkClient.h"
#import "MBProgressHUD.h"
#import "AIAcronym.h"
#import "AIMeaning.h"
#import "VariationsViewController.h"

@interface HomeViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) AIAcronym *acym;
@property (nonatomic, weak) IBOutlet UITableView *acymTView;
@property (nonatomic, weak) IBOutlet UITextField *tField;
@property (nonatomic, strong) NSCharacterSet *Characters;;

@end

@implementation HomeViewController

#pragma mark- Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetContent];
    
    // Only alpha-numeric characters are allowed to enter in textfield. below set has the disallowed characters
    self.Characters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // reset All content on screen when user starts entering any text
    [self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Textfield is disabled till user enters atleast one character.
    // Dismiss Keyboard on return
    [textField resignFirstResponder];
    if(![textField.text isEqualToString:@""]){
        
        [self fetchMeaningsForAcronym:textField.text];
    }
   
    return YES;
    
}

/*
 * delegate checks the validity of user text  entry.
 * It checks for below 3 conditions
 * 1. If entered text is less than MAXLENGTH 
 * (MAXLENGTH is set to 30. This value is configurable.)
 * 2. accept return key
 * 3. accept only alphabets and numeric characters.
*/

-(BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    
    return (newLength <= MAXLENGTH || ([string rangeOfString: @"\n"].location != NSNotFound)) && ([string rangeOfCharacterFromSet:self.Characters].location == NSNotFound);
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.acym.mng.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    AIMeaning *meaning = [self.acym.mng objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];

    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerIdentifier = @"HeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"HeaderText", @""),self.tField.text];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    // Calculate height required for title text and subtitle text. Then add padding above and below.
    AIMeaning *meaning = [self.acym.mng objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    
     NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
   
    return titleHeight + subtitleHeight + 2 * cellVerticalPadding;
    
}


#pragma mark - Web service
-(void) fetchMeaningsForAcronym: (NSString *) acronym {
  
    NSDictionary *parameters = @{@"sf": acronym};
    
    // show loading indicator when web service is made
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[AINetworkClient sharedManager] getResponseForURLString:AIBaseURL
                                                  Parameters:parameters
                                                     success:^(NSURLSessionDataTask *task, AIAcronym *acronym) {
                                                         
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.acym = acronym;
        if (self.acym && self.acym.mng.count > 0) {
            [self.acymTView setHidden:NO];
            [self.acymTView setContentOffset:CGPointZero animated:NO];
            [self.acymTView reloadData];
        }
        else{
            // show no results alerts
            [self showErrorAlertWithTitle:NSLocalizedString(@"NoResultsTitle", @"") message:[NSString stringWithFormat:NSLocalizedString(@"NoResultsMessage", @""),self.tField.text]];
        }
        
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // show error alert with error description
        [self showErrorAlertWithTitle:nil message:error.localizedDescription];
        
    }];
    
}

#pragma mark - Helper methods

-(void) resetContent{
    [self.acymTView setHidden:YES];
    self.acym = nil;
}

-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.acymTView.frame.size.width - cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}

#pragma mark - Error handling

-(void)showErrorAlertWithTitle:(NSString *) title message:(NSString *) message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alertView show];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"VariationsIdentifier"]) {
        NSIndexPath *indexPath = [self.acymTView indexPathForSelectedRow];
        VariationsViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.mng = [self.acym.mng objectAtIndex:indexPath.row];
    }
    
}


@end
