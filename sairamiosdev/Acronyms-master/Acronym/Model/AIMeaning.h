//
//  Meaning.h
//  Acronym
//
//  Created by Sairam  on 11/16/15.
 


#import <Foundation/Foundation.h>

@interface AIMeaning : NSObject
@property (nonatomic, copy) NSString *meaning;
@property NSInteger frequency;
@property NSInteger since;
@property (nonatomic, copy) NSMutableArray *variations;

@end
