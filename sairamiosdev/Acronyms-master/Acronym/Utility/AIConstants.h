//
//  AIConstants.h
//  Acronym
//
//  Created by Sairam  on 11/16/15.
 


#import <Foundation/Foundation.h>

extern NSString *const AIBaseURL;
extern NSString *const kAppFontName;
extern NSString *const kAppBoldFontName;

#define labelTextFont [UIFont fontWithName:kAppFontName size:15.0f]
#define labelBoldTextFont [UIFont fontWithName:kAppBoldFontName size:15.0f]
#define descriptionTextFont [UIFont fontWithName:kAppFontName size:13.0f]
#define cellVerticalPadding 10
#define cellHorizontalWaste 50
#define MAXLENGTH 30


@interface AIConstants : NSObject

@end
