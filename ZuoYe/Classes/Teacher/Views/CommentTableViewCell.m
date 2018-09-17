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
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 10, 36, 36)];
        [self.contentView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+12, 11, 80, 20)];
        nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+12,nameLabel.bottom, 100, 16)];
        timeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        timeLabel.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
        [self.contentView addSubview:timeLabel];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"score"]];
            [scoreArray addObject:scoreImage];
            [self addSubview:scoreImage];
        }
        
        //    评论内容
        commentLabel=[[UILabel alloc] initWithFrame:CGRectMake(nameLabel.left, timeLabel.bottom+2, kScreenWidth-97.0, 0)];
        commentLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        commentLabel.numberOfLines=0;
        commentLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [self.contentView addSubview:commentLabel];
        
    }
    return self;
}

-(void)setCommentModel:(CommentModel *)commentModel{
    _commentModel = commentModel;
    headImageView.image = [UIImage imageNamed:commentModel.head_image];
    nameLabel.text = commentModel.name;
    
    //加星级
    CGSize scoreSize = CGSizeMake(13, 13);
    double scoreNum = commentModel.score;
    NSInteger oneScroe=(NSInteger)scoreNum;
    NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
    for (int i = 0; i<scoreArray.count; i++) {
        UIImageView *scoreImage = scoreArray[i];
        [scoreImage setFrame:CGRectMake(kScreenWidth-96.0+(scoreSize.width+4.0)*i,16.0, scoreSize.width, scoreSize.height)];
        if (i<= num-1) {
            if ((i==num-1)&&scoreNum>oneScroe) {
                scoreImage.image=[UIImage imageNamed:@"score_half"];
            }
        }else{
            scoreImage.image=[UIImage imageNamed:@"score_gray"];
        }
    }
    
    timeLabel.text = commentModel.create_time;
    commentLabel.text = commentModel.comment;
    CGFloat commentH=[commentLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-97.0, CGFLOAT_MAX) withTextFont:commentLabel.font].height;
    commentLabel.frame = CGRectMake(nameLabel.left, timeLabel.bottom+2, kScreenWidth-97, commentH);
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
