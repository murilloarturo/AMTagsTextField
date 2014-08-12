//
//  TagObject.m
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

#import "TagObject.h"

@interface TagObject()

@property UIButton *deleteButton;

@end

@implementation TagObject
@synthesize deleteButton;

- (void)awakeFromNib
{
    self.deleteButton = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDeleteTagStatus:(int)deleteTagStatus
{
    if ((deleteTagStatus == showButtonToDeleteTag &&  !deleteButton) || (deleteTagStatus == buttonToDeleteTagShouldNotAppear && deleteButton)) {
        [self addRemoveTag];
    }
    
    _deleteTagStatus = deleteTagStatus;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_deleteTagStatus == buttonToDeleteTagShouldNotAppear) {
        if (self.delegate) {
            [self.delegate showFullView];
        }
    }else{
        [self addRemoveTag];
    }
}

- (void)addRemoveTag
{
    if (deleteButton) {
        _deleteTagStatus = hideButtonToDeleteTag;
        [deleteButton removeFromSuperview];
        deleteButton = nil;
    }else{
        //ShowView
        _deleteTagStatus = showButtonToDeleteTag;
        UIImage *image = [UIImage imageNamed:@"delete.png"];

        deleteButton = [[UIButton alloc] init];
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [deleteButton setFrame:CGRectMake(self.frame.size.width - (70.f/3) , 0, 70.f / 3, self.frame.size.height)];
        
        [self addSubview:deleteButton];
    }
}

- (void)deleteButtonTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate deleteTag:self];
    }else{
        [deleteButton removeFromSuperview];
        deleteButton = nil;
    }
}

@end
