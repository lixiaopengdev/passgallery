//
//  StructInfo.m
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-15.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "StructInfo.h"
#import "CommData.h"


///////////////////////////////////////////////////

@implementation StructInfo

@end


@implementation PicInfo



@end



////////////////////////////////////////////////////////////

@implementation GalleryInfo

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self )
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.imgShut = [aDecoder decodeObjectForKey:@"imgShut"];
        self.count = [aDecoder decodeObjectForKey:@"count"];
        self.isVideo = [aDecoder decodeBoolForKey:@"isVideo"];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.imgShut forKey:@"imgShut"];
    [aCoder encodeObject:self.count forKey:@"count"];
    [aCoder encodeBool:self.isVideo forKey:@"isVideo"];
}


@end
