//
//  NXJsonKitTests.m
//  NXJsonKitTests
//
//  Created by nicejinux on 02/15/2017.
//  Copyright (c) 2017 nicejinux. All rights reserved.
//

@import XCTest;

#import <NXJsonKit/NXJsonKit.h>
#import "Peoples.h"
#import "Friend.h"
#import "People.h"
#import "Pet.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformance1
{
    // This is an example of a performance test case.
    NSDictionary *dic = [self createMock];
    
    [self measureBlock:^{
        NSLog(@"START");

        NXMapper *mapper = [[NXMapper alloc] init];
        NXArrayMapping *arrayMapping = [NXArrayMapping mapForArrayItemClass:Pet.class itemKey:@"pets" onClass:People.class];
        [mapper addArrayMapping:arrayMapping];
        
        arrayMapping = [NXArrayMapping mapForArrayItemClass:People.class itemKey:@"otherFriends" onClass:People.class];
        [mapper addArrayMapping:arrayMapping];
        
        NXObjectMapping *objectMapping = [NXObjectMapping mapForJsonKey:@"others" toModelKey:@"otherFriends" onClass:People.class];
        [mapper addObjectMapping:objectMapping];
        
        objectMapping = [NXObjectMapping mapForJsonKey:@"user_name" toModelKey:@"name" onClass:People.class];
        [mapper addObjectMapping:objectMapping];
        
        objectMapping = [NXObjectMapping mapForJsonKey:@"job" toModelKey:@"jobType" onClass:People.class];
        [mapper addObjectMapping:objectMapping];
        
        NXDateMapping *dateMapping = [NXDateMapping mapForDateKey:@"birthday" format:@"yyyyMMdd" onClass:People.class];
        [mapper addDateMapping:dateMapping];
        
        NXEnumMapping *enumMapping = [NXEnumMapping mapForEnumKey:@"jobType" enumTypeList:@[@"NONE", @"DOCTOR", @"DEVELOPER", @"DESIGNER"] onClass:People.class];
        [mapper addEnumMapping:enumMapping];
        
        NXJsonKit *jsonKit = [[NXJsonKit alloc] initWithJsonData:dic mapper:mapper];
        
        Peoples *peoples = [jsonKit mappedObjectForClass:[Peoples class]];
        NSLog(@"FINISH");
    }];
}


- (void)testPerformance2
{
    NSDictionary *dic = [self createMock];
    
    [self measureBlock:^{
        NSLog(@"START");
        NSArray *list = dic[@"peopleList"];
        if (!list || list.count == 0) {
            return;
        }
        
        NSMutableArray *peopleList = [NSMutableArray new];
        for (NSDictionary *peopleDic in list) {
            People *people = [self parsePeopleWithDic:peopleDic];
            if (people) {
                [peopleList addObject:people];
            }
        }
        
        NSLog(@"FINISH");
    }];
}


- (People *)parsePeopleWithDic:(NSDictionary *)dic
{
    People *people = [People new];
    people.name = dic[@"user_name"];
    people.age = dic[@"age"];
    
    NSString *birthdayString = dic[@"birthday"];
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    dateFormmater.dateFormat = @"yyyyMMdd";
    dateFormmater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    people.birthday = [dateFormmater dateFromString:birthdayString];
    
    NSString *job = dic[@"job"];
    NSArray *enumTypeList = @[@"NONE", @"DOCTOR", @"DEVELOPER", @"DESIGNER"];
    NSUInteger index = [enumTypeList indexOfObject:job];
    people.jobType = index;
    
    NSNumber *numberOfFriends = dic[@"numberOfFriends"];
    if ([numberOfFriends isKindOfClass:[NSNumber class]]) {
        people.numberOfFriends = numberOfFriends.integerValue;
    }
    NSNumber *hasGirlFriend = dic[@"hasGirlFriend"];
    if ([hasGirlFriend isKindOfClass:[NSNumber class]]) {
        people.hasGirlFriend = hasGirlFriend.boolValue;
    }
    NSNumber *height = dic[@"height"];
    if ([height isKindOfClass:[NSNumber class]]) {
        people.height = height.doubleValue;
    }
    people.myfriend = [self parseFriendWithDic:dic[@"myfriend"]];
    people.pets = [self parsePetsWithList:dic[@"pets"]];
    people.otherFriends = [self parseOthersWithDic:dic[@"others"]];
    
    return people;
}


- (Friend *)parseFriendWithDic:(NSDictionary *)dic
{
    Friend *friend = [Friend new];
    friend.name = dic[@"name"];
    friend.pet = [self parsePetWithDic:dic[@"pet"]];
    
    return friend;
}


- (NSArray *)parsePetsWithList:(NSArray *)list
{
    if (![list isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *pets = [NSMutableArray new];
    for (NSDictionary *dic in list) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        Pet *pet = [self parsePetWithDic:dic];
        if (pet) {
            [pets addObject:pet];
        }
    }
    
    return pets;
}


- (Pet *)parsePetWithDic:(NSDictionary *)dic
{
    Pet *pet = [Pet new];
    pet.kind = dic[@"kind"];
    pet.name = dic[@"name"];
    pet.age = dic[@"age"];
    return pet;
}


- (NSArray *)parseOthersWithDic:(NSArray *)list
{
    if (![list isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *others = [NSMutableArray new];
    for (NSDictionary *dic in list) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        People *people = [self parsePeopleWithDic:dic];
        if (people) {
            [others addObject:people];
        }
    }
    
    return others;
}


- (NSMutableDictionary *)createMock
{
    NSMutableArray *list = [NSMutableArray new];
    for (int i=0; i<1000; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        
        dic[@"user_name"] = @"Nicejinux";
        dic[@"age"] = @40;
        dic[@"numberOfFriends"] = @3;
        dic[@"hasGirlFriend"] = @(false);
        dic[@"height"] = @178.5;
        dic[@"pets"] = @[
                         @{
                             @"kind":@"dog",
                             @"name":@"doggy",
                             @"age":@"2 years"
                             }, @{
                             @"kind":@"cat",
                             @"name":@"kitty",
                             @"age":@"1 year"
                             }
                         ];
        
        dic[@"myfriend"] = @{
                             @"name":@"tom",
                             @"pet":
                                 @{
                                     @"kind":@"cat",
                                     @"name":@"catty",
                                     @"age":@"3 years"
                                     }
                             };
        
        dic[@"others"] = @[
                           @{
                               @"user_name" : @"Qneek",
                               @"age"  : @40,
                               @"pets" : @[
                                       @{
                                           @"kind":@"dog",
                                           @"name":@"doggy",
                                           @"age":@"2 years"
                                           }, @{
                                           @"kind":@"cat",
                                           @"name":@"eitty",
                                           @"age":@"4 monthes"
                                           }, @{
                                           @"kind":@"cat",
                                           @"name":@"kitty",
                                           @"age":@"1 year"
                                           }
                                       ]
                               },
                           @{
                               @"user_name" : @"Max",
                               @"age"  : @40
                               }, @{
                               @"user_name" : @"Kim",
                               @"age"  : @40,
                               @"pets" : @[
                                       @{
                                           @"kind":@"dog",
                                           @"name":@"doggy",
                                           @"age":@"2 years"
                                           }
                                       ]
                               }
                           ];
        [list addObject:dic];
    }
    
    NSMutableDictionary *mockData = [NSMutableDictionary new];
    mockData[@"peopleList"] = list;
    
    return mockData;
}

@end

