//
//  HZBAddressBookUtil.m
//  AddressBook
//
//  Created by 安宁 on 2017/5/11.
//  Copyright © 2017年 安宁. All rights reserved.
//


//ips：如果要适配iOS 10，就必须在plist文件的Source code模式下添加
///<key>NSContactsUsageDescription</key>  Privacy - Contacts Usage Description
///<string>App需要您的同意,才能访问通讯录</string>

#import "HZBAddressBookUtil.h"
// iOS 9前的框架
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

// iOS 9的新框架
#import <ContactsUI/ContactsUI.h>


#define Is_up_Ios_9             ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)

@interface HZBAddressBookUtil () <ABPeoplePickerNavigationControllerDelegate , CNContactPickerDelegate>

@property ( nonatomic , copy ) void(^callbackContacts)(HZBContactsModel * model , ErrorEnum error) ;

@property ( nonatomic , retain )  UIViewController * viewController ;

@end

@implementation HZBAddressBookUtil

#pragma mark ---- 调用系统通讯录
-(void)getContacts:(void (^)(HZBContactsModel * model , ErrorEnum error))callback  viewController:(UIViewController * )vc
{
    
    [self setCallbackContacts:callback] ;
    [self setViewController:vc];

    __block typeof(callback) bCallback  = callback ;
    
    ///获取通讯录权限，调用系统通讯录
    [self checkAddressBookAuthorization:^(bool isAuthorized , bool isUp_ios_9) {
        if (isAuthorized)
        {
            [self callAddressBook:isUp_ios_9];
        }else
        {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
            
            bCallback(nil,NoAuthorized);
        }
    } ];
}

- (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized , bool isUp_ios_9))block
{
    if (Is_up_Ios_9)
    {
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined)
        {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                    block(NO,YES);
                }
                else if (!granted)
                {
                    
                    block(NO,YES);
                }
                else
                {
                    block(YES,YES);
                }
            }];
        } else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
        {
            block(YES,YES);
        } else
        {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
            block(NO,YES);
        }
    }else
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        
        if (authStatus == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)
                    {
                        NSLog(@"Error: %@", (__bridge NSError *)error);
                        block(NO,NO);
                    }
                    else if (!granted)
                    {
                        
                        block(NO,NO);
                    }
                    else
                    {
                        block(YES,NO);
                    }
                });
            });
        }else if (authStatus == kABAuthorizationStatusAuthorized)
        {
            block(YES,NO);
        }else
        {
            NSLog(@"请到设置>隐私>通讯录打开本应用的权限设置");
            block(NO,NO);
            
        }
    }
}

- (void)callAddressBook:(BOOL)isUp_ios_9
{
    if (isUp_ios_9)
    {
        CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [_viewController presentViewController:contactPicker animated:YES completion:nil];
    }else
    {
        ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
        peoplePicker.peoplePickerDelegate = self;
        [_viewController presentViewController:peoplePicker animated:YES completion:nil];
        
    }
}

#pragma mark -- CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    __block typeof(self.callbackContacts) bCallback  = self.callbackContacts ;

    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
    [_viewController dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *text1 = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName,contactProperty.contact.givenName];
        /// 电话
        NSString *text2 = phoneNumber.stringValue;
        //                text2 = [text2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSLog(@"联系人：%@, 电话：%@",text1,text2);
        
        HZBContactsModel * model = [[HZBContactsModel alloc]init];
        model.userName = text1 ;
        model.userPhone = text2 ;
        bCallback(model,Authorized);

    }];
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    __block typeof(self.callbackContacts) bCallback  = self.callbackContacts ;

    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    
    [_viewController dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *text1 = [NSString stringWithFormat:@"%@",anFullName];
        /// 电话
        NSString *text2 = (__bridge NSString*)value;
        //                text2 = [text2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSLog(@"联系人：%@, 电话：%@",text1,text2);
        
        HZBContactsModel * model = [[HZBContactsModel alloc]init];
        model.userName = text1 ;
        model.userPhone = text2 ;
        bCallback(model,Authorized);
    }];
}


@end
