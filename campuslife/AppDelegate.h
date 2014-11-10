//
//  AppDelegate.h
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    Reachability *internetReach;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, setter=setHasService:,getter=getHasService) BOOL hasService;

@end

