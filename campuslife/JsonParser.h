//
//  JsonParser.h
//  LCSC
//
//  Created by x on 4/19/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonParser : NSObject
+(NSArray *)loadEventsFromMonth:(NSInteger) startMonth andYear:(NSInteger)startYear toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear;


@end
