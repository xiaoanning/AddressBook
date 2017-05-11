//
//  ViewController.m
//  AddressBook
//
//  Created by 安宁 on 2017/5/11.
//  Copyright © 2017年 安宁. All rights reserved.
//

#import "ViewController.h"
#import "HZBAddressBookUtil.h"


@interface ViewController ()
{
    HZBAddressBookUtil * _util ;
}
@property ( nonatomic , copy ) void(^callbackContacts)(HZBContactsModel * model , ErrorEnum error) ;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"======== %@",[[UIDevice currentDevice]systemVersion]);
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //注意_util 不能被提前释放 否则不会执行回调
    _util = [[HZBAddressBookUtil alloc]init] ;
    [_util getContacts:^(HZBContactsModel *model, ErrorEnum error) {
        
        if (model)
        {
            NSLog(@"%@ %ld",model ,error);
        }else
        {
            if (error == NoAuthorized)
            {
                NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
            }
        }
        
    } viewController:self];

}




@end
