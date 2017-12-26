//
//  ViewController.m
//  DummyCode
//
//  Created by c.W on 2017/12/22.
//  Copyright © 2017年 c.W. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#include <stdlib.h>
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

@interface ViewController()

typedef NS_ENUM(NSInteger, GSCSourceType) {
    GSCSourceTypeClass,
    GSCSourceTypeCategory,
};

@property (strong) NSString *gOutParameterName;
@property (strong) NSString *gSourceCodeDir;
@property (strong) NSString *outDirString ;
@property (strong) NSArray *classSecondNameArray;
@property (strong) NSArray        *letters;
@property (strong) NSMutableSet   *classNameSet;
@property NSInteger number;
@property (strong) NSString *basePath;

@end

static NSMutableArray *classFirstNameArray;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)run:(id)sender {
    
    @autoreleasepool {
        
        self.basePath = @"/Users/a4399/Desktop/tmld";
        
        
        // 原项目路径（与.xcodeproj文件同一层级）
        self.gSourceCodeDir = self.basePath;
        // 修改png资源文件
        BOOL needHandleXcassets = NO;
        // 删除注释
        BOOL needDeleteComments = NO;
        // 新旧工程名称
        BOOL needChangeProjectName = NO;
        NSString *oldProjectName = @"Cherish";
        NSString *newProjectName = @"CherishWang";
        // 修改类名前缀
        BOOL needChangePrefix = NO;
        NSString *projectFilePath = [self.basePath stringByAppendingString:@"/Cherish.xcodeproj"];
        NSString *oldClassNamePrefix = @"";
        NSString *newClassNamePrefix = @"";
        // 生成垃圾代码
        BOOL needGenerateSpamCode = YES;
        self.outDirString = [self.basePath stringByAppendingString:@"/out"];
        self.gOutParameterName = @"AppLog";
        classFirstNameArray = [[NSMutableArray alloc] init];
        self.classSecondNameArray = @[@"c",@"d"];
        self.classNameSet = [NSMutableSet new];
        //英文字母
        self.letters = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
        // 忽略文件列表
        NSArray<NSString *> *ignoreDirNames = nil;
        
        BOOL isDirectory = NO;
        
        // 开始
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.gSourceCodeDir isDirectory:&isDirectory]) {
            printf("%s不存在\n", [self.gSourceCodeDir UTF8String]);
            exit(0);
        }
        if (!isDirectory) {
            printf("%s不是目录\n", [self.gSourceCodeDir UTF8String]);
            exit(0);
        }
        
        // 修改png资源文件
        if (needHandleXcassets) {
            @autoreleasepool {
                [self handleXcassetsFiles:self.gSourceCodeDir];
            }
            printf("修改 Xcassets 中的图片名称完成\n");
        }
        
        // 删除注释
        if (needDeleteComments) {
            @autoreleasepool {
                [self deleteComments:self.gSourceCodeDir ];
            }
            printf("删除注释和空行完成\n");
        }
        
        // 修改前缀
        if (needChangePrefix && projectFilePath && oldClassNamePrefix && newClassNamePrefix) {
            @autoreleasepool {
                
                // 打开工程文件
                NSError *error = nil;
                NSMutableString *projectContent = [NSMutableString stringWithContentsOfFile:projectFilePath encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    printf("打开工程文件 %s 失败：%s\n", projectFilePath.UTF8String, error.localizedDescription.UTF8String);
                    exit(0);
                }
                
                [self modifyClassNamePrefix:projectContent: self.gSourceCodeDir: ignoreDirNames: oldClassNamePrefix: newClassNamePrefix];
                
                [projectContent writeToFile:projectFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            printf("修改类名前缀完成\n");
        }
        
        // 生成垃圾代码
        if (needGenerateSpamCode && self.outDirString && self.gOutParameterName) {
            
            if ([fm fileExistsAtPath:self.outDirString isDirectory:&isDirectory]) {
                if (!isDirectory) {
                    printf("%s 已存在但不是文件夹，需要传入一个输出文件夹目录\n", [self.outDirString UTF8String]);
                    exit(0);
                }
            } else {
                NSError *error = nil;
                if (![fm createDirectoryAtPath:self.outDirString withIntermediateDirectories:YES attributes:nil error:&error]) {
                    printf("创建输出目录失败，请确认 -spamCodeOut 之后接的是一个“输出文件夹目录”参数，错误信息如下：\n传入的输出文件夹目录：%s\n%s\n", [self.outDirString UTF8String], [error.localizedDescription UTF8String]);
                    exit(0);
                }
            }
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
            if ([regex numberOfMatchesInString:self.gOutParameterName options:0 range:NSMakeRange(0, self.gOutParameterName.length)] <= 0) {
                printf("缺少垃圾代码参数名，或参数名\"%s\"不合法(需要字母开头)\n", [self.gOutParameterName UTF8String]);
                exit(0);
            }
            
            
            recursiveDirectory(self.gSourceCodeDir, ignoreDirNames, ^(NSString *mFilePath) {
                @autoreleasepool {
                    [self generateSpamCodeFile:self.outDirString: mFilePath: GSCSourceTypeClass];
                    [self generateSpamCodeFile:self.outDirString: mFilePath: GSCSourceTypeCategory];
                }
            }, ^(NSString *swiftFilePath) {
                @autoreleasepool {
                    [self generateSwiftSpamCodeFile:self.outDirString: swiftFilePath];
                }
            });
            printf("生成垃圾代码完成\n");
        }
        
        // 根据模板生成垃圾代码
        [self generateTemplateCode];
        [self generateImport];
        
        // 修改工程名
        if(needChangeProjectName && oldProjectName && newProjectName){
            @autoreleasepool {
                NSString *dir = self.gSourceCodeDir.stringByDeletingLastPathComponent;
                [self modifyProjectName:dir: oldProjectName: newProjectName];
            }
            printf("修改工程名完成\n");
        }
        
    }
    
    exit(0);
    
    
}

#pragma mark - 公共方法

static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomString:(NSInteger) length {
    NSMutableString *ret = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [ret appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((uint32_t)[kRandomAlphabet length])]];
    }
    return ret;
}

- (NSRange) getOutermostCurlyBraceRange :(NSString *)string begin:(unichar) beginChar end:(unichar) endChar index:(NSInteger) beginIndex {
    NSInteger braceCount = -1;
    NSInteger endIndex = string.length - 1;
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == beginChar) {
            braceCount = ((braceCount == -1) ? 0 : braceCount) + 1;
        } else if (c == endChar) {
            braceCount--;
        }
        if (braceCount == 0) {
            endIndex = i;
            break;
        }
    }
    return NSMakeRange(beginIndex + 1, endIndex - beginIndex - 1);
}

- (NSString *) getSwiftImportString:(NSString *)string {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [string substringWithRange:obj.range];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

- (BOOL) regularReplacement:(NSMutableString *)originalString: (NSString *)regularExpression: (NSString *)newString {
    __block BOOL isChanged = NO;
    BOOL isGroupNo1 = [newString isEqualToString:@"\\1"];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isChanged) {
            isChanged = YES;
        }
        if (isGroupNo1) {
            NSString *withString = [originalString substringWithRange:[obj rangeAtIndex:1]];
            [originalString replaceCharactersInRange:obj.range withString:withString];
        } else {
            [originalString replaceCharactersInRange:obj.range withString:newString];
        }
    }];
    return isChanged;
}

-(void) renameFile:(NSString *)oldPath: (NSString *)newPath {
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {
        printf("修改文件名称失败。\n  oldPath=%s\n  newPath=%s\n  ERROR:%s\n", oldPath.UTF8String, newPath.UTF8String, error.localizedDescription.UTF8String);
        abort();
    }
}



#pragma mark - 生成垃圾代码

void recursiveDirectory(NSString *directory, NSArray<NSString *> *ignoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath)) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
    
        
        if ([filePath rangeOfString:@"+"].location == NSNotFound
            && [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z]+$"] evaluateWithObject:[filePath substringToIndex:1]]
            ){
            NSString *path = [directory stringByAppendingPathComponent:filePath];
            if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
                if (![ignoreDirNames containsObject:filePath]) {
                    recursiveDirectory(path, nil, handleMFile, handleSwiftFile);
                }
                continue;
            }
            NSString *fileName = filePath.lastPathComponent;
            if ([fileName hasSuffix:@".h"]) {
                fileName = [fileName stringByDeletingPathExtension];
                
                NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
                if ([files containsObject:mFileName]) {
                    handleMFile([directory stringByAppendingPathComponent:mFileName]);
                }
                
                [classFirstNameArray addObject:fileName];
                
                
            } else if ([fileName hasSuffix:@".swift"]) {
                handleSwiftFile([directory stringByAppendingPathComponent:fileName]);
            }
        }
    }
}

NSString * getImportString(NSString *hFileContent, NSString *mFileContent) {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *[@#]import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:hFileContent options:0 range:NSMakeRange(0, hFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [hFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [mFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

static NSString *const kHClassFileTemplate = @"\
%@\n\
@interface %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kMClassFileTemplate = @"\
#import \"%@%@.h\"\n\
@implementation %@ (%@)\n\
%@\n\
@end\n";

-(void) generateSpamCodeFile:(NSString *)outDirectory: (NSString *)mFilePath:(GSCSourceType) type {
    NSString *mFileContent = [NSString stringWithContentsOfFile:mFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *regexStr;
    switch (type) {
        case GSCSourceTypeClass:
            regexStr = @" *@implementation +(\\w+)[^(]*\\n(?:.|\\n)+?@end";
            break;
        case GSCSourceTypeCategory:
            regexStr = @" *@implementation *(\\w+) *\\((\\w+)\\)(?:.|\\n)+?@end";
            break;
    }
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *hFilePath = [mFilePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"h"];
    NSString *hFileContent = [NSString stringWithContentsOfFile:hFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 准备要引入的文件
    NSString *importString = getImportString(hFileContent, mFileContent);
    
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull impResult, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = [mFileContent substringWithRange:[impResult rangeAtIndex:1]];
        NSString *categoryName = nil;
        if (impResult.numberOfRanges >= 3) {
            categoryName = [mFileContent substringWithRange:[impResult rangeAtIndex:2]];
        }
        
        if (type == GSCSourceTypeClass) {
            // 如果该类型没有公开，只在 .m 文件中使用，则不处理
            NSString *regexStr = [NSString stringWithFormat:@"\\b%@\\b", className];
            NSRange range = [hFileContent rangeOfString:regexStr options:NSRegularExpressionSearch];
            if (range.location == NSNotFound) {
                return;
            }
        }
        
        // 查找方法
        NSString *implementation = [mFileContent substringWithRange:impResult.range];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *([-+])[^)]+\\)([^;{]+)" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:implementation options:0 range:NSMakeRange(0, implementation.length)];
        if (matches.count <= 0) return;
        
        // 生成 h m 垃圾文件内容
        NSMutableString *hFileMethodsString = [NSMutableString string];
        NSMutableString *mFileMethodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *symbol = [implementation substringWithRange:[matche rangeAtIndex:1]];
            NSString *methodName = [[implementation substringWithRange:[matche rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([methodName containsString:@":"]) {
                methodName = [methodName stringByAppendingFormat:@" %@:(NSString *)%@", self.gOutParameterName, self.gOutParameterName];
            } else {
                methodName = [methodName stringByAppendingFormat:@"%@:(NSString *)%@", self.gOutParameterName.capitalizedString, self.gOutParameterName];
            }
            
            [hFileMethodsString appendFormat:@"%@ (void)%@;\n", symbol, methodName];
            
            [mFileMethodsString appendFormat:@"%@ (void)%@ {\n", symbol, methodName];
            [mFileMethodsString appendFormat:@"    NSLog(@\"%%@\", %@);\n", self.gOutParameterName];
            [mFileMethodsString appendString:@"}\n"];
        }];
        
        NSString *newCategoryName;
        switch (type) {
            case GSCSourceTypeClass:
                newCategoryName = self.gOutParameterName.capitalizedString;
                break;
            case GSCSourceTypeCategory:
                newCategoryName = [NSString stringWithFormat:@"%@%@", categoryName, self.gOutParameterName.capitalizedString];
                break;
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@.h", className, newCategoryName];
        NSString *fileContent = [NSString stringWithFormat:kHClassFileTemplate, importString, className, newCategoryName, hFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        fileName = [NSString stringWithFormat:@"%@%@.m", className, newCategoryName];
        fileContent = [NSString stringWithFormat:kMClassFileTemplate, className, newCategoryName, className, newCategoryName, mFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

static NSString *const kSwiftFileTemplate = @"\
%@\n\
extension %@ {\n%@\
}\n";
static NSString *const kSwiftMethodTemplate = @"\
func %@%@(_ %@: String%@) {\n\
print(%@)\n\
}\n";

-(void) generateSwiftSpamCodeFile:(NSString *)outDirectory: (NSString *)swiftFilePath {
    NSString *swiftFileContent = [NSString stringWithContentsOfFile:swiftFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 查找 class 声明
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@" *(class|struct) +(\\w+)[^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:swiftFileContent options:0 range:NSMakeRange(0, swiftFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *fileImportStrings = [self getSwiftImportString:swiftFileContent];
    __block NSInteger braceEndIndex = 0;
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull classResult, NSUInteger idx, BOOL * _Nonnull stop) {
        // 已经处理到该 range 后面去了，过掉
        NSInteger matchEndIndex = classResult.range.location + classResult.range.length;
        if (matchEndIndex < braceEndIndex) return;
        // 是 class 方法，过掉
        NSString *fullMatchString = [swiftFileContent substringWithRange:classResult.range];
        if ([fullMatchString containsString:@"("]) return;
        
        NSRange braceRange = [self getOutermostCurlyBraceRange:swiftFileContent begin: '{' end: '}' index:matchEndIndex];
        braceEndIndex = braceRange.location + braceRange.length;
        
        // 查找方法
        NSString *classContent = [swiftFileContent substringWithRange:braceRange];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"func +([^(]+)\\([^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:classContent options:0 range:NSMakeRange(0, classContent.length)];
        if (matches.count <= 0) return;
        
        NSMutableString *methodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull funcResult, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange funcNameRange = [funcResult rangeAtIndex:1];
            NSString *funcName = [classContent substringWithRange:funcNameRange];
            NSRange oldParameterRange = [self getOutermostCurlyBraceRange:classContent begin: '('  end: ')' index: funcNameRange.location + funcNameRange.length];
            NSString *oldParameterName = [classContent substringWithRange:oldParameterRange];
            oldParameterName = [oldParameterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (oldParameterName.length > 0) {
                oldParameterName = [@", " stringByAppendingString:oldParameterName];
            }
            [methodsString appendFormat:kSwiftMethodTemplate, funcName, self.gOutParameterName.capitalizedString, self.gOutParameterName, oldParameterName, self.gOutParameterName];
        }];
        if (methodsString.length <= 0) return;
        
        NSString *className = [swiftFileContent substringWithRange:[classResult rangeAtIndex:2]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@Ext.swift", className, self.gOutParameterName.capitalizedString];
        NSString *filePath = [outDirectory stringByAppendingPathComponent:fileName];
        NSString *fileContent = @"";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        fileContent = [fileContent stringByAppendingFormat:kSwiftFileTemplate, fileImportStrings, className, methodsString];
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

#pragma mark - 处理 Xcassets 中的图片文件

-(void) handleXcassetsFiles:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            [self handleXcassetsFiles:filePath];
            continue;
        }
        if (![fileName isEqualToString:@"Contents.json"]) continue;
        NSString *contentsDirectoryName = filePath.stringByDeletingLastPathComponent.lastPathComponent;
        if (![contentsDirectoryName hasSuffix:@".imageset"]) continue;
        
        NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!fileContent) continue;
        
        NSMutableArray<NSString *> *processedImageFileNameArray = @[].mutableCopy;
        static NSString * const regexStr = @"\"filename\" *: *\"(.*)?\"";
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        while (matches.count > 0) {
            NSInteger i = 0;
            NSString *imageFileName = nil;
            do {
                if (i >= matches.count) {
                    i = -1;
                    break;
                }
                imageFileName = [fileContent substringWithRange:[matches[i] rangeAtIndex:1]];
                i++;
            } while ([processedImageFileNameArray containsObject:imageFileName]);
            if (i < 0) break;
            
            NSString *imageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:imageFileName];
            if ([fm fileExistsAtPath:imageFilePath]) {
                NSString *newImageFileName = [[self randomString:10] stringByAppendingPathExtension:imageFileName.pathExtension];
                NSString *newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                while ([fm fileExistsAtPath:newImageFileName]) {
                    newImageFileName = [[self randomString:10] stringByAppendingPathExtension:imageFileName.pathExtension];
                    newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                }
                
                [self renameFile:imageFilePath: newImageFilePath];
                
                fileContent = [fileContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", imageFileName]
                                                                     withString:[NSString stringWithFormat:@"\"%@\"", newImageFileName]];
                [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [processedImageFileNameArray addObject:newImageFileName];
            } else {
                [processedImageFileNameArray addObject:imageFileName];
            }
            
            matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        }
    }
}

#pragma mark - 删除注释

-(void) deleteComments:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            [self deleteComments:filePath];
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".swift"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [self regularReplacement:fileContent: @"([^:/])//.*":             @"\\1"];
        [self regularReplacement:fileContent: @"^//.*":                   @""];
        [self regularReplacement:fileContent: @"/\\*{1,2}[\\s\\S]*?\\*/": @""];
        [self regularReplacement:fileContent: @"^\\s*\\n":                @""];
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

#pragma mark - 修改工程名

-(void) resetEntitlementsFileName:(NSString *)projectPbxprojFilePath: (NSString *)oldName:(NSString *)newName {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"CODE_SIGN_ENTITLEMENTS = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"entitlements"]];
        [self renameFile:entitlementsPath: newPath];
    }];
}

-(void) resetBridgingHeaderFileName:(NSString *)projectPbxprojFilePath: (NSString *)oldName: (NSString *)newName {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"SWIFT_OBJC_BRIDGING_HEADER = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"h"]];
        [self renameFile:entitlementsPath: newPath];
    }];
}

-(void) replacePodfileContent:(NSString *)filePath:(NSString *)oldString:(NSString *)newString {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"target +'%@", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"target '%@", newString]];
    }];
    
    regularExpression = [NSString stringWithFormat:@"project +'%@.", oldString];
    expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"project '%@.", newString]];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) replaceProjectFileContent:(NSString *)filePath:(NSString *)oldString: (NSString *)newString {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:newString];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) modifyProjectName:(NSString *)projectDir:(NSString *)oldName:(NSString *)newName {
    NSString *sourceCodeDirPath = [projectDir stringByAppendingPathComponent:oldName];
    NSString *xcodeprojFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcodeproj"];
    NSString *xcworkspaceFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcworkspace"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // old-Swift.h > new-Swift.h
    [self modifyFilesClassName:projectDir: [oldName stringByAppendingString:@"-Swift.h"]: [newName stringByAppendingString:@"-Swift.h"]];
    
    // 改 Podfile 中的工程名
    NSString *podfilePath = [projectDir stringByAppendingPathComponent:@"Podfile"];
    if ([fm fileExistsAtPath:podfilePath isDirectory:&isDirectory] && !isDirectory) {
        [self replacePodfileContent:podfilePath: oldName: newName];
    }
    
    // 改工程文件内容
    if ([fm fileExistsAtPath:xcodeprojFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 project.pbxproj 文件内容
        NSString *projectPbxprojFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.pbxproj"];
        if ([fm fileExistsAtPath:projectPbxprojFilePath]) {
            [self resetBridgingHeaderFileName:projectPbxprojFilePath:[oldName stringByAppendingString:@"-Bridging-Header"]:[newName stringByAppendingString:@"-Bridging-Header"]];
            [self resetEntitlementsFileName:projectPbxprojFilePath: oldName:newName];
            [self replaceProjectFileContent:projectPbxprojFilePath:oldName: newName];
        }
        // 替换 project.xcworkspace/contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            [self replaceProjectFileContent:contentsXcworkspacedataFilePath: oldName: newName];
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        [self renameFile:xcodeprojFilePath: [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcodeproj"]];
    }
    
    // 改工程组文件内容
    if ([fm fileExistsAtPath:xcworkspaceFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            [self replaceProjectFileContent:contentsXcworkspacedataFilePath:oldName:newName];
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        [self renameFile:xcworkspaceFilePath:[[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcworkspace"]];
    }
    
    // 改源代码文件夹名称
    if ([fm fileExistsAtPath:sourceCodeDirPath isDirectory:&isDirectory] && isDirectory) {
        [self renameFile:sourceCodeDirPath:[projectDir stringByAppendingPathComponent:newName]];
    }
}

#pragma mark - 修改类名前缀

-(void )modifyFilesClassName:(NSString *)sourceCodeDir:(NSString *)oldClassName:( NSString *)newClassName {
    // 文件内容 Const > DDConst (h,m,swift,xib,storyboard)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            [self modifyFilesClassName:path: oldClassName: newClassName];
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("打开文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
            
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldClassName];
            BOOL isChanged = [self regularReplacement:fileContent: regularExpression: newClassName];
            if (!isChanged) continue;
            error = nil;
            [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("保存文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
        }
    }
}

-(void) modifyClassNamePrefix:(NSMutableString *)projectContent:(NSString *)sourceCodeDir:(NSArray<NSString *> *)ignoreDirNames:(NSString *)oldName:(NSString *)newName {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 遍历源代码文件 h 与 m 配对，swift
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![ignoreDirNames containsObject:filePath]) {
                [self modifyClassNamePrefix:projectContent: path: ignoreDirNames: oldName: newName];
            }
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        NSString *fileExtension = filePath.pathExtension;
        NSString *newClassName;
        if ([fileName hasPrefix:oldName]) {
            newClassName = [newName stringByAppendingString:[fileName substringFromIndex:oldName.length]];
        } else {
            newClassName = [newName stringByAppendingString:fileName];
        }
        
        // 文件名 Const.ext > DDConst.ext
        if ([fileExtension isEqualToString:@"h"]) {
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                [self renameFile:oldFilePath: newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"m"];
                [self renameFile:oldFilePath: newFilePath];
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    [self renameFile:oldFilePath: newFilePath];
                }
                
                @autoreleasepool {
                    [self modifyFilesClassName:self.gSourceCodeDir: fileName: newClassName];
                }
            } else {
                continue;
            }
        } else if ([fileExtension isEqualToString:@"swift"]) {
            NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"swift"];
            NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"swift"];
            [self renameFile:oldFilePath: newFilePath];
            oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
            if ([fm fileExistsAtPath:oldFilePath]) {
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                [self renameFile:oldFilePath: newFilePath];
            }
            
            @autoreleasepool {
                [self modifyFilesClassName:self.gSourceCodeDir: fileName.stringByDeletingPathExtension: newClassName];
            }
        } else {
            continue;
        }
        
        // 修改工程文件中的文件名
        NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", fileName];
        [self regularReplacement:projectContent: regularExpression: newClassName];
    }
    
}

-(void) generateTemplateCode{
    
    self.number = [classFirstNameArray count] * [self.classSecondNameArray count];
    
    
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    
    NSString *templatePath_h = [[NSBundle mainBundle] pathForResource:@"DummyClass_h" ofType:@"txt"];
    NSString *templatePath_m = [[NSBundle mainBundle] pathForResource:@"DummyClass_m" ofType:@"txt"];
    
    if (self.number == 0) {
        return;
    } else {
        self.classNameSet = [self getClassName];
        NSEnumerator *enumerator = [self.classNameSet objectEnumerator];
        NSString *className;
        while (className = [enumerator nextObject]) {
            NSMutableArray *firstParamsArray = [self getFirstMethodParams];
            NSMutableArray *secondParamsArray = [self getSecondMethodParams];
            NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:
                                       firstParamsArray, @"firstMethodParams",
                                       secondParamsArray, @"secondMethodParams",
                                       className, @"ClassName",
                                       nil];
            NSString *resultH = [engine processTemplateInFileAtPath:templatePath_h withVariables:variables];
            NSString *resultM = [engine processTemplateInFileAtPath:templatePath_m withVariables:variables];
            
            NSString *bundel=[[NSBundle mainBundle] resourcePath];
            NSString *deskTopLocation=self.outDirString;
            NSString *pathH = [deskTopLocation stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", className]];
            NSString *pathM = [deskTopLocation stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", className]];
            BOOL isSuccessH = [resultH writeToFile:pathH atomically:YES encoding:NSUTF8StringEncoding error:nil];
            BOOL isSuccessM = [resultM writeToFile:pathM atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            if (isSuccessH && isSuccessM) {
                NSLog(@"success");
            } else {
                NSLog(@"fail");
            }
            
        }
    }
    
}

-(NSMutableArray *)getFirstMethodParams {
    //拼接参数名
    NSMutableArray *paramsArray = [NSMutableArray new];
    int paramsNumber = (arc4random() % 1) + 4;
    
    for (int i = 0; i < paramsNumber; i ++) {
        //这个参数有多少个字母组成
        int paramLength = (arc4random() % 6) + 2;
        //组成这个参数
        NSString *param;
        for (int j = 0; j < paramLength; j ++) {
            if (param.length == 0) {
                param = self.letters[arc4random() % 26];
            }
            else {
                param = [NSString stringWithFormat:@"%@%@",param,self.letters[arc4random() % 26]];
            }
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:param, @"key", @"NSString", @"value", nil];
        [paramsArray addObject:dic];
    }
    return paramsArray;
}

-(NSMutableArray *)getSecondMethodParams{
    //拼接参数名
    NSMutableArray *paramsArray = [NSMutableArray new];
    
    int paramsNumber = (arc4random() % 1) + 2;
    for (int i = 0; i < paramsNumber; i ++) {
        //这个参数有多少个字母组成
        int paramLength = (arc4random() % 6) + 2;
        //组成这个参数
        NSString *param;
        for (int j = 0; j < paramLength; j ++) {
            if (param.length == 0) {
                param = self.letters[arc4random() % 26];
            }
            else {
                param = [NSString stringWithFormat:@"%@%@",param,self.letters[arc4random() % 26]];
            }
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:param, @"key", @"NSString", @"value", nil];
        [paramsArray addObject:dic];
    }
    return paramsArray;
}

-(NSMutableSet *)getClassName {
    //拼接类名
    NSMutableSet *classNameSet = [NSMutableSet new];
    for (int i = 0; i < self.number; i ++) {
        int firstName = arc4random() % classFirstNameArray.count;
        int secondName = arc4random() % self.classSecondNameArray.count;
        NSString *firstNameString = classFirstNameArray[firstName];
        NSString *secondNameString = self.classSecondNameArray[secondName];
        NSString *name =  [NSString stringWithFormat:@"%@%@",firstNameString,secondNameString];
        [classNameSet addObject:name];
    }
    return classNameSet;
}

-(void)generateImport{
    
    if (self.classNameSet.count == 0) {
        return;
    }
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    
    NSString *templatePath_h = [[NSBundle mainBundle] pathForResource:@"ImportClass_h" ofType:@"txt"];
    NSString *templatePath_m = [[NSBundle mainBundle] pathForResource:@"ImportClass_m" ofType:@"txt"];
    
    NSMutableArray *nameArray = [self getImporNameArray];
    NSDictionary *variable = [NSDictionary dictionaryWithObjectsAndKeys:
                              nameArray, @"ClassName",
                              nil];
    
    NSString *resultH = [engine processTemplateInFileAtPath:templatePath_h withVariables:variable];
    NSString *resultM = [engine processTemplateInFileAtPath:templatePath_m withVariables:variable];
    NSString *bundel=[[NSBundle mainBundle] resourcePath];
    NSString *deskTopLocation=self.outDirString;
    NSString *pathH = [deskTopLocation stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", @"ImportClass"]];
    NSString *pathM = [deskTopLocation stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", @"ImportClass"]];
    BOOL isSuccessH = [resultH writeToFile:pathH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    BOOL isSuccessM = [resultM writeToFile:pathM atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if (isSuccessH && isSuccessM) {
        NSLog(@"success");
    } else {
        NSLog(@"fail");
    }
    
    
}

-(NSMutableArray *)getImporNameArray {
    NSArray *nameArray = [self.classNameSet allObjects];
    NSMutableArray *nameMutableArray = [NSMutableArray new];
    [nameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:nameArray[idx], @"key", @"NSString", @"value", nil];
        [nameMutableArray addObject:dic];
    }];
    return nameMutableArray;
}


@end
