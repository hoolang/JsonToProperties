//
//  JsonToProperties.h
//  JsonToProperties
//
//  Created by Circle on 16/7/29.
//  Copyright © 2016年 Hoolang. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface JsonToProperties : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end