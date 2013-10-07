//
//  DocumentManager.m
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager


+ (NSString *) filePath:(NSString *)fileName
{

    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the file
    return  [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     fileName]];
    
}

+ (UIImage *) getImage: (NSString *)fileName
{
//    NSLog([NSString stringWithFormat:@"DocumentManager getImage with fileName= %@",fileName]);
    NSData *imageData = [NSData dataWithContentsOfFile:[DocumentManager filePath:fileName]];
    return  [UIImage imageWithData:imageData];
}

@end
