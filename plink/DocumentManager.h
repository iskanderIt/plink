//
//  DocumentManager.h
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentManager : NSObject


+ (NSString *) filePath:(NSString *)fileName;

+ (UIImage *) getImage: (NSString *)fileName;

@end
