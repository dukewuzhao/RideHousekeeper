//
//  CFSettingTableViewController.h
//  TableViewSettingList
//
//  Created by wangchangfei on 15/9/24.
//  Copyright (c) 2015年 wangchangfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFSettingTableViewController : BaseViewController

@property (nonatomic, strong) UITableView *table;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataList;

/** cell中显示的箭头名称 */
@property(nonatomic,copy)NSString* icon_arrow;

/** cell背景颜色 */
@property (nonatomic, strong) UIColor *backgroundColor_Normal;

/** cell选中背景颜色 */
@property (nonatomic, strong) UIColor *backgroundColor_Selected;

/** cell左边Label字体 */
@property (nonatomic, strong) UIFont *leftLabelFont;

/** cell左边Label字体颜色 */
@property (nonatomic, strong) UIColor *leftLabelFontColor;

/** cell右边Label字体 */
@property (nonatomic, strong) UIFont *rightLabelFont;

/** cell右边Label字体颜色 */
@property (nonatomic, strong) UIColor *rightLabelFontColor;

@end
