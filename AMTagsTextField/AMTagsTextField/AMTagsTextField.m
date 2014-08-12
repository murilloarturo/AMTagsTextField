//
//  AMTagsTextField.m
//  AMTagsTextField
//
//  Created by Arturo Murillo on 6/18/14.
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

#import "AMTagsTextField.h"
#import "TagTextField.h"
#import "TagHelpers.h"

@interface AMTagsTextField()

@property UILabel *placeHolderLabel;
@property (nonatomic, strong) TagTextField *textfield;
@property (nonatomic, strong) TagPopoverController *popover;
@property (nonatomic) NSMutableArray *tags; //of TagObject
@property (nonatomic) UIColor *tagColor;
@property (nonatomic) BOOL viewShouldGrow;

@property int cursorX;
@property int cursorY;
@property float heightForTag;
@property float minimalWidth;
@property float iconSpace;
@property float originalHeight;
@property (nonatomic) float horizontalSpacing;
@property (nonatomic) float verticalSpacing;

@end

@implementation AMTagsTextField
@synthesize tags;
@synthesize textfield;
@synthesize popover;
@synthesize cursorX;
@synthesize cursorY;
@synthesize heightForTag;
@synthesize minimalWidth;
@synthesize iconSpace;

- (NSMutableArray *)tags
{
    if (tags) {
        return tags;
    }
    
    tags = [[NSMutableArray alloc] init];
    
    return tags;
}

- (void)awakeFromNib
{
    self.horizontalSpacing = 5;
    self.verticalSpacing = 5;
    minimalWidth = 70.f;
    heightForTag = 30.f;
    self.originalHeight = self.frame.size.height;
    iconSpace = 10.f;
    
    [self setupPopover];
    [self setupTextfield];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupPopover
{
    popover = [[TagPopoverController alloc] init];
    popover.tagPopoverDelegate = self;
    
    //NSMutableArray *array = [NSMutableArray arrayWithArray:@[@{@"name":@"Wrocław", @"color": @""}, @{@"name":@"Malmo", @"color": @""}, @{@"name":@"Oslo", @"color": @""}, @{@"name":@"Berlin", @"color": @""}, @{@"name":@"Amsterdam", @"color": @""}, @{@"name":@"Praha", @"color": @""}, @{@"name":@"Paris", @"color": @""}, @{@"name":@"Barcelona", @"color": @""}, @{@"name":@"Madrid", @"color": @""}]];
    
    //[popover setTagArray:array];
}

- (void)setupTextfield
{
    cursorX = self.horizontalSpacing;
    cursorY = self.verticalSpacing;
    
    textfield = [[TagTextField alloc] init];
    [textfield setFrame:CGRectMake(cursorX, cursorY, self.frame.size.width, heightForTag)];
    [textfield setText:@"\u200B"];
    
    textfield.delegate = self;
    
    [textfield addTarget:self action:@selector(textFieldEditDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self setPlaceholder:NSLocalizedString(@"Tags", nil)];
    
    [self showOrHidePlaceHolderLabel];
    
    __weak __typeof(self)weakSelf = self;
    
    [textfield setDetectBackSpaceBlock:^{
        if ([weakSelf.tags count] > 0) {
            TagObject *lastTag = [weakSelf.tags lastObject];
            if (lastTag.deleteTagStatus == showButtonToDeleteTag) {
                [weakSelf deleteTag:lastTag];
            }else{
                [lastTag setDeleteTagStatus:showButtonToDeleteTag];
            }
        }
    }];

    [self addSubview:textfield];
}

#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self updateToFullView];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self textFieldHasNoSpaces]) {
        [self addTagWithName:textfield.text andColor:nil];
    }
    
    [self updateToMinimalView];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self textFieldHasNoSpaces]){
        [self addTagWithName:textField.text andColor:nil];
    }
    
    return NO;
}

- (void)textFieldEditDidChange:(UITextField *)textField
{
    [popover matchTagsForString:textfield.text];
    
    [self showOrHidePlaceHolderLabel];
}

- (BOOL)textFieldHasNoSpaces
{
    NSString *stringSpaces = [textfield.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    NSString *stringWithoutSpaces = [stringSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return ([stringWithoutSpaces length] > 0 && ![stringWithoutSpaces isEqualToString:@"\u200B"]);
}

- (void) showOrHidePlaceHolderLabel
{
	[_placeHolderLabel setHidden:!([textfield.text isEqualToString:@"\u200B"] || [textfield.text isEqualToString:@""])];
}

- (void)setPlaceholder:(NSString *)placeholder {
	
	if (placeholder){
        UILabel * label =  _placeHolderLabel;
		if (!label || ![label isKindOfClass:[UILabel class]]){
			label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 5, 5)];
			[label setTextColor:[UIColor colorWithWhite:0.75 alpha:1]];
            _placeHolderLabel = label;
            [self.textfield addSubview: _placeHolderLabel];
		}
		
		[label setText:placeholder];
		[label sizeToFit];
	}
	else
	{
		[_placeHolderLabel removeFromSuperview];
		_placeHolderLabel = nil;
	}
}

#pragma mark - add remove Tag

- (void)allowToGrow:(BOOL)toGrow
{
    self.viewShouldGrow = toGrow;
    if (!toGrow) {
        [self setPlaceholder:@""];
    }
}

- (void)showBorders:(BOOL)show
{
    if (show) {
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }else{
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }
}

- (void)setSuggestedTags:(NSMutableArray *)suggestedTags
{
    //recives array of dictionary
    // {name:NameOfTag, color:colorHexString}
    [popover setTagArray:suggestedTags];
    
    //Maybe minimal
    [self updateToMinimalView];
}

- (void)setTags:(NSMutableArray *)newTags
{
    //recives array of dictionary
    // {name:NameOfTag, color:colorHexString}
    tags = [self dictionariesToTagObjectsArray:newTags];
    
    [popover setSelectedArray:newTags];
    
    //Maybe minimal
    [self updateToMinimalView];
}

- (void)setColorTag:(UIColor *)color
{
    if (color) {
        self.tagColor = color;
    }
}

- (NSArray *)getSelectedTags
{
    return [self tagObjectsToDictionaryArray];
}

- (void)addTagWithName:(NSString *)name andColor:(UIColor *)color
{
    float widthForTag = (([name length] * iconSpace) + iconSpace < minimalWidth) ? minimalWidth : ([name length] * iconSpace) + iconSpace;
    
    TagObject *tag = [[TagObject alloc] init];
    [tag setTitle:name forState:UIControlStateNormal];
    
    if (color) {
        [tag setBackgroundColor:color];
    }else if (self.tagColor) {
        [tag setBackgroundColor:self.tagColor];
    }else{
        [tag setBackgroundColor:[UIColor greenColor]];
    }
    
    [tag setFrame:CGRectMake(cursorX, cursorY, widthForTag, heightForTag)];
    
    tag.delegate = self;
    
    tag.layer.cornerRadius = tag.frame.size.height /2;
    tag.layer.masksToBounds = YES;
    tag.layer.borderWidth = 0;
    
    [self.tags addObject:tag];
    
    [self updateToFullView];
}

- (void)deleteTag:(id)tag
{
    if ([self.tags containsObject:tag]) {
        [popover addTagToArray:[self dictionaryFromTag:tag]];
        
        [tag removeFromSuperview];
        [self.tags removeObject:tag];
        
        [self updateToFullView];
    }
}

#pragma mark - updateView

- (void)updateToMinimalView
{
    for (int i = [self.subviews count] - 1; i > 0; i--) {
        UIView *subview = self.subviews[i];
        [subview removeFromSuperview];
    }
    
    cursorX = self.horizontalSpacing;
    cursorY = self.verticalSpacing;
    
    [self updateViewHeight:self.originalHeight toOriginalHeight:YES];
    //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalHeight)];
    
    int i = 0;
    
    for (TagObject *tag in self.tags) {
        if (cursorX + tag.frame.size.width < self.frame.size.width && cursorX + (minimalWidth *2)< self.frame.size.width) {
            [tag setDeleteTagStatus:buttonToDeleteTagShouldNotAppear];
            
            [tag setFrame:CGRectMake(cursorX, cursorY, tag.frame.size.width, tag.frame.size.height)];
            
            [self addSubview:tag];
            
            cursorX = cursorX + tag.frame.size.width + self.horizontalSpacing;
            
            i++;
        }else{
            break;
        }
    }
    
    if (i > 0 && i < [self.tags count]) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(cursorX, cursorY, minimalWidth, heightForTag)];
        [button setTitleColor:[UIColor colorWithWhite:0.75 alpha:1] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"+%d", [self.tags count] - i] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(showFullView) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [textfield setHidden:YES];
    }
}

//local and delegate for TagObject
- (void) showFullView
{
    if (self.viewShouldGrow) {
        [textfield setHidden:NO];
        
        [self updateToFullView];
        
        [textfield becomeFirstResponder];
    }
}

- (void)updateToFullView
{
    for (int i = [self.subviews count] - 1; i > 0; i--) {
        UIView *subview = self.subviews[i];
        [subview removeFromSuperview];
    }
    
    cursorX = self.horizontalSpacing;
    cursorY = self.verticalSpacing;
    
    [self updateViewHeight:self.originalHeight toOriginalHeight:YES];
    //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalHeight)];
    
    for (TagObject *tag in self.tags) {
        float width = tag.frame.size.width;
        
        if (cursorX + tag.frame.size.width >= self.frame.size.width) {
            if (tag.frame.size.width >= self.frame.size.width) {
                //El Tag pasa el borde
                width = minimalWidth * 4;
                if (cursorX + minimalWidth*4 >= self.frame.size.width) {
                    //verifico que el widthminimo se puede agregar;
                    //si no cumple salto a la siguiente linea
                    cursorX = self.horizontalSpacing;
                    cursorY = cursorY + tag.frame.size.height + self.verticalSpacing;
                    
                    //aumento el tamano de la vista
                    [self updateViewHeight:heightForTag + self.verticalSpacing toOriginalHeight:NO];
                    //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + heightForTag + self.verticalSpacing)];
                }
            }else{
                //salto a la siguiente linea
                cursorX = self.horizontalSpacing;
                cursorY = cursorY + tag.frame.size.height + self.verticalSpacing;
                
                //aumento el tamano de la vista
                [self updateViewHeight:heightForTag + self.verticalSpacing toOriginalHeight:NO];
                //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + heightForTag + self.verticalSpacing)];
            }
        }
        
        tag.deleteTagStatus = hideButtonToDeleteTag;
        
        [tag setFrame:CGRectMake(cursorX, cursorY, width, tag.frame.size.height)];
        
        [self addSubview:tag];
        
        cursorX = cursorX + tag.frame.size.width + self.horizontalSpacing;
        
        if (cursorX >= self.frame.size.width - (minimalWidth + iconSpace)) {
            cursorX = self.horizontalSpacing;
            cursorY = cursorY + tag.frame.size.height + self.verticalSpacing;
            
            //aumento el tamano de la vista
            [self updateViewHeight:heightForTag + self.verticalSpacing toOriginalHeight:NO];
            
            //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + heightForTag + self.verticalSpacing)];
            
        }
    }
    
    [self updateTextfieldFrame];
}

- (void)updateTextfieldFrame
{
    [textfield setFrame:CGRectMake(cursorX, cursorY, self.frame.size.width - cursorX, textfield.frame.size.height)];
    [textfield setText:@"\u200B"];
    [self showPopover];
    [self showOrHidePlaceHolderLabel];
}

#pragma mark - change height of view
- (void)updateViewHeight:(float)height toOriginalHeight:(BOOL)toOriginalHeight;
{
    if (toOriginalHeight) {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
        
        if (self.delegate) {
            [self.delegate returnViewToOriginalHeight];
        }
    }else{
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + height)];
        
        if (self.delegate) {
            [self.delegate increaseHeightOfView:height];
        }
    }
}

#pragma mark - TagPopOverDelegate

- (void)addTag:(NSDictionary *)tag
{
    //get color from Functions
    if ([tag valueForKey:@"name"] != [NSNull null] && [tag valueForKey:@"color"] != [NSNull null]) {
        [self addTagWithName:[tag valueForKey:@"name"]  andColor:[TagHelpers colorFromHex:[tag valueForKey:@"color"]]];
    }
}

- (void)showPopover
{
    if ([self shouldDismissPopover]) {
        [popover dismissPopoverAnimated:YES];
    }else if([self shouldShowPopover]){
        [popover presentPopoverFromRect:textfield.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }else{
        //other case
    }
}

- (BOOL)shouldDismissPopover
{
    return (([popover.matchedTags count] == 0 || ![self textFieldHasNoSpaces] || [textfield.text isEqualToString:@"\u200B"]) && [popover isPopoverVisible]);
}

- (BOOL)shouldShowPopover
{
    return (![popover isPopoverVisible] && [popover.matchedTags count] > 0);
}

#pragma mark - tagToDictionary/dictionaryToTag

- (NSDictionary *)dictionaryFromTag:(TagObject *)tag
{
    if ([tag.titleLabel.text rangeOfString:@"\u200B"].location == NSNotFound) {
        return @{@"name": tag.titleLabel.text, @"color": [TagHelpers hexStringForColor:tag.backgroundColor]};
    } else {
        NSString *name = [tag.titleLabel.text stringByReplacingCharactersInRange:[tag.titleLabel.text rangeOfString:@"\u200B"] withString:@""];
        
        return @{@"name": name, @"color": [TagHelpers hexStringForColor:tag.backgroundColor]};
    }
}

- (NSArray *)tagObjectsToDictionaryArray
{
    NSMutableArray *tagDictionaryArray = [[NSMutableArray alloc] init];
    
    for (TagObject *tag in self.tags) {
        [tagDictionaryArray addObject:[self dictionaryFromTag:tag]];
    }
    
    return tagDictionaryArray;
}

- (TagObject *)dictionaryToTagObject:(NSDictionary *)dictionary
{
    float widthForTag = (([[dictionary valueForKey:@"name"] length] * iconSpace) + iconSpace < minimalWidth) ? minimalWidth : ([[dictionary valueForKey:@"name"] length] * iconSpace) + iconSpace;
    
    TagObject *tag = [[TagObject alloc] init];
    [tag setTitle:[dictionary valueForKey:@"name"] forState:UIControlStateNormal];
    
    UIColor *color = [TagHelpers colorFromHex:[dictionary valueForKey:@"color"]];
    
    if (color) {
        [tag setBackgroundColor:color];
    }else{
        [tag setBackgroundColor:[UIColor greenColor]];
    }
    
    [tag setFrame:CGRectMake(cursorX, cursorY, widthForTag, heightForTag)];
    
    tag.delegate = self;
    
    tag.layer.cornerRadius = tag.frame.size.height /2;
    tag.layer.masksToBounds = YES;
    tag.layer.borderWidth = 0;
    
    return tag;
}

- (NSMutableArray *)dictionariesToTagObjectsArray:(NSArray *)dictionaries
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *tagDictionary in dictionaries) {
        if ([tagDictionary valueForKey:@"name"] != [NSNull null] && [tagDictionary valueForKey:@"color"] != [NSNull null]) {
            [array addObject:[self dictionaryToTagObject:tagDictionary]];
        }
    }
    
    return array;
}

@end