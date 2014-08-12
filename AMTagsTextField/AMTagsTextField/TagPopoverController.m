//
//  TagPopoverController.m
//  AMTagsTextField
//
//  Created by Arturo Murillo on 6/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "TagPopoverController.h"
#import "TagHelpers.h"

#define DEFAULT_POPOVER_SIZE CGSizeMake(200, 150)

@interface TagPopoverController()

@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;

@property (nonatomic) UITableViewController *tableViewController;

@property (nonatomic) NSString *lastWord;
@property (nonatomic) NSNumber *tagOriginX;

@property (nonatomic) NSMutableArray *tagsArray; //array of Dictionary {name, color}

@property (nonatomic) NSMutableArray *selectedTags; //array of Dictionary: {name, color}

@end

@implementation TagPopoverController
@synthesize horizontalPadding, verticalPadding;
#pragma mark - Setup

- (id)init
{
    self = [super initWithContentViewController:self.tableViewController];
    
    [self setup];
    
    return self;
}

- (NSMutableArray *)tagsArray
{
    if (_tagsArray) {
        return _tagsArray;
    }
    
    _tagsArray = [[NSMutableArray alloc] init];
    
    return _tagsArray;
}

- (NSArray *)matchedTags
{
    if (_matchedTags) {
        return _matchedTags;
    }
    
    _matchedTags = [[NSArray alloc] init];
    
    return _matchedTags;
}

- (NSMutableArray *)selectedTags
{
    if (_selectedTags) {
        return _selectedTags;
    }
    
    _selectedTags = [[NSMutableArray alloc] init];
    
    return _selectedTags;
}

- (UITableViewController *)tableViewController
{
    if (_tableViewController) {
        return _tableViewController;
    }
    
    _tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    return _tableViewController;
}

- (void)setup
{
    self.tagOriginX = @5;
    
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.dataSource = self;
    
    [self.tableViewController.tableView setBounces:NO];
    
    // Default values
    //self.popoverContentSize = DEFAULT_POPOVER_SIZE;
    
    self.shouldHideOnSelection = NO;
    
    //self.selectedTags = [[NSMutableArray alloc] init];
}

- (void)setTagArray:(NSMutableArray *)tags
{
    NSPredicate *notIn = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.tagsArray];
    
    [self.tagsArray addObjectsFromArray:[tags filteredArrayUsingPredicate:notIn]];
}

- (void)setSelectedArray:(NSArray *)selectedTags
{
    [self.selectedTags addObjectsFromArray:selectedTags];
}

#pragma mark - Matching strings and Popover

- (void)matchTagsForString:(NSString *)string
{
    if ([string length] > 0 && ![string isEqualToString:@"\u200B"] && [self.tagsArray count] > 0){
        NSMutableArray *predicates = [[NSMutableArray alloc] init];
        
        //para quitar el caracter especial \u200B
        NSPredicate *contains = nil;
        if ([[string substringToIndex:1] isEqualToString:@"\u200B"]) {
            contains = [NSPredicate predicateWithFormat:@"name contains[cd] %@",[string substringFromIndex:1]];
        }else{
            contains = [NSPredicate predicateWithFormat:@"name contains[cd] %@", string];
        }
        
        NSPredicate *notIn = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.selectedTags];
        
        [predicates addObject:contains];
        [predicates addObject:notIn];
        
        self.matchedTags = [self.tagsArray filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        [self.tableViewController.tableView reloadData];
        
        NSLog(@"table conten width %f && height %f", self.tableViewController.tableView.contentSize.width, self.tableViewController.tableView.contentSize.height );
        
        if (self.tableViewController.tableView.contentSize.width < 1 || self.tableViewController.tableView.contentSize.height < 1) {
            self.popoverContentSize = CGSizeMake(748.f, 84.f);
        }else{
            self.popoverContentSize = self.tableViewController.tableView.contentSize;
        }
    }
    
    if (self.tagPopoverDelegate) {
        [self.tagPopoverDelegate showPopover];
    }
}

- (void)addTagToArray:(NSDictionary *)tag
{
    
    if ([tag valueForKey:@"name"] != [NSNull null] && [tag valueForKey:@"color"] != [NSNull null] && ![self.tagsArray containsObject:tag]) {
        [self.tagsArray addObject:tag];
    }
}

- (void)searchForMatches
{
    NSPredicate *notIn = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.selectedTags];
    
    self.matchedTags = [self.tagsArray filteredArrayUsingPredicate:notIn];
    [self.tableViewController.tableView reloadData];
}

#pragma mark - TableView Delegate & DataSource

- (NSDictionary *)itemAtIndexPath:(NSIndexPath*)path
{
    return [self.matchedTags objectAtIndex:path.row];
}

- (id)selectedItem
{
    return [self itemAtIndexPath:[self.tableViewController.tableView indexPathForSelectedRow]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchedTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //agrego solo el nombre pues
    NSDictionary *tag = [self itemAtIndexPath:indexPath];
    //UIColor *color = [Functions colorFromHex:tag.color];
    
    NSString *name = [tag valueForKey:@"name"];
    NSString *colorString = [tag valueForKey:@"color"];
    UIColor *color = [UIColor greenColor];
    
    if (colorString) {
        //Functions get color From hex
        color = [TagHelpers colorFromHex:colorString];
    }
    
    UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(20, 14, 20, 20)];
    [colorView setBackgroundColor:color];
    
    [cell addSubview:colorView];
    
    cell.textLabel.text = name;
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tagPopoverDelegate) {
        [self.tagPopoverDelegate addTag: [self itemAtIndexPath:indexPath]];
        
        [self.tagPopoverDelegate showPopover];
        
        if (![self.selectedTags containsObject:[self itemAtIndexPath:indexPath]]) {
            [self.selectedTags addObject:[self itemAtIndexPath:indexPath]];
        }
        
        [self searchForMatches];
        
        [self dismissPopoverAnimated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //I have a static list of section titles in SECTION_ARRAY for reference.
    //Obviously your own section title code handles things differently to me.
    return NSLocalizedString(@"Tags", nil);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
@end
