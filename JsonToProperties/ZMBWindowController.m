//
//  ZMBWindowController.m
//  ZMBJsonToModel
//
//  Created by Circle on 16/7/29.
//  Copyright © 2016年 Hoolang. All rights reserved.
//

#import "ZMBWindowController.h"
#import <Carbon/Carbon.h>

@interface ZMBWindowController ()

@property (weak) IBOutlet NSScrollView *textView;
@property (weak) IBOutlet NSButton *confirmButton;
@property (weak) IBOutlet NSButton *cancelButton;

@end

@implementation ZMBWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)clickConvertButton:(id)sender {
    NSTextView * textView= [_textView documentView];
    NSLog(@"_textView.inputContext ===> %@", [textView.textStorage string]);
    
    NSError *err = nil;
    id dic = [self initWithString:[textView.textStorage string] usingEncoding:NSUTF8StringEncoding error:&err];
    
    NSString *properties = @"";
    
    if (dic == nil) {
        NSLog(@"error");
        return;
    }else{
        if ([dic isKindOfClass:[NSDictionary class]]) {
            properties = [self convertToProperty:dic];
        }else return;
    }
    
    //Save current content in paste board
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    
    //Set the doc comments in it
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:properties forType:NSStringPboardType];
    
    [self close];
    
    CGEventSourceRef _source;
    CGEventTapLocation _location;

    _source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    _location = kCGHIDEventTap;

    NSInteger keyCode = kVK_ANSI_V;
    
    CGEventRef event;
    event = CGEventCreateKeyboardEvent(_source, keyCode, true);
    CGEventSetFlags(event, kCGEventFlagMaskCommand);
    CGEventPost(_location, event);
    CFRelease(event);
}

- (IBAction)clickCancelButton:(id)sender {
    [self close];
    NSLog(@"clickCancelButton");
}

-(id)initWithString:(NSString *)string usingEncoding:(NSStringEncoding)encoding error:(NSError**)err
{
    //check for nil input
    if (!string) {
        return nil;
    }
    
    NSError* initError = nil;
    id objModel = [self initWithData:[string dataUsingEncoding:encoding] error:&initError];
    if (initError && err) *err = initError;
    return objModel;
    
}

-(instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)err
{
    //read the json
    NSError* initError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions
                                               error:&initError];
    
    if (initError) {
        return nil;
    }
    
    //init with dictionary
//    id objModel = [self initWithDictionary:obj error:&initError];
    if (initError && err) *err = initError;
    return obj;
}

- (NSString *)convertToProperty:(NSDictionary *)dic
{
    NSArray *allKeys = [dic allKeys];
    NSString *properties = @"";
    
    for (int i = 0; i < allKeys.count; i++) {
        id value = [dic objectForKey:allKeys[i]];
        if ([value isKindOfClass:[NSString class]] || [value isEqual:[NSNull null]]) {
            properties = [NSString stringWithFormat:@"%@@property (nonatomic, copy) NSString *%@;\n", properties, allKeys[i]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            properties = [NSString stringWithFormat:@"%@@property (nonatomic, strong) NSArray *%@;\n", properties, allKeys[i]];
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            properties = [NSString stringWithFormat:@"%@@property (nonatomic, strong) NSDictionary *%@;\n", properties, allKeys[i]];
        }
        else
        {
            properties = [NSString stringWithFormat:@"%@@property (nonatomic, assign) NSInteger %@;\n", properties, allKeys[i]];
        }
    }
    return properties;
}

@end
