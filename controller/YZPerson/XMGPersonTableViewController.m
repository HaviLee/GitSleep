//
//  XMGPersonTableViewController.m
//  个人详情控制器
//
//  Created by yz on 15/8/13.
//  Copyright (c) 2015年 yz. All rights reserved.
//

#import "XMGPersonTableViewController.h"

@interface XMGPersonTableViewController ()

@end

@implementation XMGPersonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID
                ];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog([NSString stringWithFormat:@"%ld",(long)(int)indexPath.row]);
}
@end
