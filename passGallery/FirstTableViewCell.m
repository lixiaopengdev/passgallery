//
//  FirstTableViewCell.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "FirstTableViewCell.h"

@interface FirstTableViewCell()
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIImageView *shutImgView;


@end

@implementation FirstTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0, 70-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor =[UIColor colorWithWhite:0.9 alpha:1];
    [self.contentView addSubview:line];
    self.backgroundColor = UIColor.whiteColor;
    self.contentView.backgroundColor = UIColor.whiteColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)refreshCell:(GalleryInfo*)info
{
    _nameLab.text = info.name;
    _countLab.text = [NSString stringWithFormat:@"%@张",(info.count? info.count:@"0")];
    
    _shutImgView.image = info.imgShut? [UIImage imageWithData:info.imgShut]:(info.isVideo?[UIImage imageNamed:@"video_icon"] : [UIImage imageNamed:@"lib"]);
    if (info.isVideo) {
        _shutImgView.backgroundColor = [UIColor clearColor];

    } else {
        _shutImgView.backgroundColor = [UIColor orangeColor];

    }
}

@end
