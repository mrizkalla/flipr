//
//  FlickrCell.m
//  flipr
//
//  Created by Priyanka Bhalerao on 2/2/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "FlickrCell.h"
@interface FlickrCell()
@property (weak, nonatomic) UIButton *checkButton;
@end

@implementation FlickrCell

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
 */

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
        bgView.layer.borderWidth = 2;
        self.backgroundView = bgView;
        
        //Check button for selection
        /*
        UIImage *checkImage = [UIImage imageNamed:@"Selection.png"];
        self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.checkButton setFrame:CGRectMake(105, 30, 30, 30)];
        [self.checkButton setImage:checkImage forState:UIControlStateNormal];*/
        UIImage *checkImage = [UIImage imageNamed:@"Selection.png"];
        UIImageView *checkHolder = [[UIImageView alloc]initWithFrame:CGRectMake(100,4,30,30)];
        checkHolder.image = checkImage;
        UIView *selbgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        [selbgView addSubview:checkHolder];
        self.selectedBackgroundView = selbgView;
       
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
/*
-(void) prepareForReuse{
   [super prepareForReuse];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self setSelected:NO];
    self.selectedBackgroundView = Nil;
}*/

@end
