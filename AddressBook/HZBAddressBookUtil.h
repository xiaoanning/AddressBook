//
//  HZBAddressBookUtil.h
//  AddressBook
//
//  Created by 安宁 on 2017/5/11.
//  Copyright © 2017年 安宁. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HZBContactsModel.h"


typedef NS_ENUM(NSUInteger, ErrorEnum)
{
    Authorized = 0 ,

    NoAuthorized = 1 ,
};


@interface HZBAddressBookUtil : NSObject   

-(void)getContacts:(void(^)(HZBContactsModel * model , ErrorEnum error))callback viewController:(UIViewController * )vc ;

@end
