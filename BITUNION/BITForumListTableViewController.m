//
//  BITForumListTableViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/26.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITForumListTableViewController.h"
#import "BITNetManager.h"
#import "NSString+URLEncode.h"
#import "BITUserInfo.h"
#import "NSDictionary+BITJSONString.h"
#import "BITThreadListTableViewController.h"
#import "MJRefresh.h"


@interface BITForumListTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *forumDict;
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, strong) NSString *fid;

@end

@implementation BITForumListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupArray = [[NSMutableArray alloc] init];
    _forumDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getFourmGroup)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)];
    [self.tableView.mj_header beginRefreshing];

}

- (void)getTotalFid {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session,
                                @"fid": @"*",
                                @"tid": @"*"
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_fid_tid.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求论坛列表成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSString *totalFid = response[@"fid"];
            NSLog(@"%@", totalFid);
//            NSDictionary* dict =[NSDictionary dictionaryWithDictionary: response[@"forumslist"]];
//            NSArray * keys = [dict allKeys];
//
//            NSLog(@"%@", keys);
//            for (NSString *key in keys) {
//                if (![key isEqualToString:@""]) {
//                    NSString *groupName = [dict[key][@"main"][@"name"] stringByRemovingPercentEncoding];
//
//                    NSLog(@"%@", groupName);
//                    [self.groupArray addObject:groupName];
//                    NSMutableDictionary *aDict =
//                    [NSMutableDictionary dictionaryWithDictionary:dict[key]];
//                    [self.forumDict setValue:aDict forKey:groupName];
//                }
//            }
            
        } else {
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_groupArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithString:_groupArray[section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [_groupArray objectAtIndex:section];
    NSDictionary *groupDict = [_forumDict objectForKey:key];
    return [[groupDict allKeys] count] -1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    
    NSString *key = [_groupArray objectAtIndex:indexPath.section];
    NSDictionary *aDict = [_forumDict objectForKey:key];
    NSString *fourmKey = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSArray *_fourmMainDict = [[aDict objectForKey: fourmKey] objectForKey:@"main"];
    NSString *textLabelText =[(NSString *)_fourmMainDict[0][@"name"] stringByRemovingPercentEncoding];
    
    cell.textLabel.text = textLabelText;
    NSMutableString *detailText = [NSMutableString string];
    NSArray *fourmSubDicts = [[aDict objectForKey: fourmKey] objectForKey:@"sub"];
    
    for (NSDictionary *subDict in fourmSubDicts) {
        NSString *str = [subDict[@"name"] stringByRemovingPercentEncoding];
        [detailText appendString:str];
        [detailText appendString:@"  "];
    }
    cell.detailTextLabel.text = detailText;
        
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [_groupArray objectAtIndex:indexPath.section];
    NSDictionary *aDict = [_forumDict objectForKey:key];
    NSString *fourmKey = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSArray *_fourmMainDict = [[aDict objectForKey: fourmKey] objectForKey:@"main"];
    NSString *fid = [[_fourmMainDict objectAtIndex:0] objectForKey:@"fid"];
    
    [self performSegueWithIdentifier:@"xxxx" sender:fid];
   }

- (void)getMore {
    [self getFourmGroup];
    
}

- (void) getFourmGroup{
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{@"action":@"forum",
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_forum.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求论坛列表成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSDictionary* dict =[NSDictionary dictionaryWithDictionary: response[@"forumslist"]];
            NSArray * keys = [dict allKeys];
            
            for (NSString *key in keys) {
                if (![key isEqualToString:@""]) {
                    NSString *groupName = [dict[key][@"main"][@"name"] stringByRemovingPercentEncoding];
                    
                    [self.groupArray addObject:groupName];
                    NSMutableDictionary *aDict =
                    [NSMutableDictionary dictionaryWithDictionary:dict[key]];
                    [self.forumDict setValue:aDict forKey:groupName];
                }
            }
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
        } else {
            [BITNetManager relogin];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *fid = sender;
    BITThreadListTableViewController *threadListController = segue.destinationViewController;
        threadListController.fid = fid;

}



@end
