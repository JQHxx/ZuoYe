//
//  CommentTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "LabelsView.h"

@interface CommentTableViewCell (){
    UIImageView   *headImageView;
    UILabel       *nameLabel;
    UILabel       *timeLabel;
    UILabel       *commentLabel;
    
    NSMutableArray  *scoreArray;
}


@end

@implementation CommentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, 5, 150, 20)];
        nameLabel.font = kFontWithSize(14);
        nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-140, 10, 130, 20)];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = kFontWithSize(13);
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_ic_star"]];
            [scoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
        //    评论内容
        commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, headImageView.bottom+5, kScreenWidth-headImageView.right-20, 0)];
        commentLabel.font=[UIFont systemFontOfSize:14];
        commentLabel.numberOfLines=0;
        commentLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:commentLabel];
        
    }
    return self;
}

-(void)setCommentModel:(CommentModel *)commentModel{
    _commentModel = commentModel;
    headImageView.image = [UIImage imageNamed:commentModel.head_image];
    nameLabel.text = commentModel.name;
    
    //加星级
    CGSize scoreSize = CGSizeMake(15, 15);
    double scoreNum = commentModel.score;
    NSInteger oneScroe=(NSInteger)scoreNum;
    NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
    for (int i = 0; i<scoreArray.count; i++) {
        UIImageView *scoreImage = scoreArray[i];
        [scoreImage setFrame:CGRectMake(headImageView.right+10+scoreSize.width*i,nameLabel.bottom+5, scoreSize.width, scoreSize.height)];
        if (i<= num-1) {
            if ((i==num-1)&&scoreNum>oneScroe) {
                scoreImage.image=[UIImage imageNamed:@"pub_ic_star_half"];
            }
        }else{
            scoreImage.image=[UIImage imageNamed:@"pub_ic_star_un"];
        }
    }
    
    timeLabel.text = commentModel.create_time;
    commentLabel.text = commentModel.comment;
    CGFloat commentH=[commentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-headImageView.right-20, CGFLOAT_MAX) withTextFont:commentLabel.font].height;
    commentLabel.frame = CGRectMake(nameLabel.left, headImageView.bottom+5, kScreenWidth-headImageView.right-20, commentH);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
