//
//  HZBContactsModel.m
//  AddressBook
//
//  Created by 安宁 on 2017/5/11.
//  Copyright © 2017年 安宁. All rights reserved.
//

#import "HZBContactsModel.h"

@implementation HZBContactsModel

-(NSString *)description
{
    return [NSString stringWithFormat:@"userName : %@ ; userPhone : %@",_userName,_userPhone];
}

@end
