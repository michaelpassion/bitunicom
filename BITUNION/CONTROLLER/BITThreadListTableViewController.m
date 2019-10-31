//
//  BITForumDetailListTableViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2018/7/2.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITThreadListTableViewController.h"
#import "BITHeaders.h"
#import "MJRefresh.h"
#import "BITThreadTableViewCell.h"
#import "BITTopicListTableViewController.h"


@interface BITThreadListTableViewController ()

@property (nonatomic, strong) NSMutableArray *threadArray;
@property (nonatomic, assign) NSUInteger start;
@property (nonatomic, assign) NSUInteger end;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, assign) NSUInteger totalFid;


@end

@implementation BITThreadListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _threadArray = [[NSMutableArray alloc] init];
    _start = 0;
    _end = _start + 20;
    _tid = [[NSString alloc] init];
    
    UINib *cellNib = [UINib nibWithNibName:@"BITThreadTableViewCell" bundle:nil];

    [self.tableView registerNib: cellNib forCellReuseIdentifier:@"BITThreadCellIdentfier"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getThreadList)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)];

    [self getTotalFid];
    
}

- (void)getMore {
    if (_end < _totalFid) {
        _start = _end;
        _end = _end + 20>_totalFid?_totalFid:_end+20;
        [self getThreadList];
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
   
}
- (void)getTotalFid {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session,
                                @"tid": @"*",
                                @"fid": _fid,
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_fid_tid.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSString *totalFid = response[@"fid_sum"];
            self.totalFid = [totalFid integerValue];
            [self.tableView.mj_header beginRefreshing];
            
        } else {
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}

- (void)getThreadList {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    NSDictionary *parameter = @{@"action":@"thread",
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session,
                                @"fid":_fid,
                                @"from":[NSString stringWithFormat:@"%ld",(long)_start],
                                @"to":[NSString stringWithFormat:@"%ld",(long)_end]
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_thread.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求论坛列表成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSArray * array = response[@"threadlist"];
//            NSLog(@"%@", array);
            [self.threadArray addObjectsFromArray:array];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];

        } else {
//            [BITNetManager relogin];
//            [self getThreadList];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_threadArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BITThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BITThreadCellIdentfier" forIndexPath:indexPath] ;
    
    NSDictionary *thredDetailDict = _threadArray[indexPath.row];
    
//    NSString* subject = [NSString stringWithFormat:@"%@ (%@)", [self convertUnicode:thredDetailDict[@"subject"]], [self convertUnicode:thredDetailDict[@"replies"]]];
    NSString* subject = [NSString stringWithFormat:@"%@ (%@)",
        [thredDetailDict[@"subject"]  URLDecodedString],
        [thredDetailDict[@"replies"] URLDecodedString]];
    NSString* author = [self convertUnicode:thredDetailDict[@"author"]];
    NSString* time = [self covertTimeStamp:thredDetailDict[@"lastpost"]];
    NSMutableAttributedString *attrSubject = [[NSMutableAttributedString alloc] initWithData:[subject dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),} documentAttributes:nil error:nil];
    [attrSubject addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]*1.3]} range:NSMakeRange(0, attrSubject.length)];
    cell.topicLabel.attributedText = attrSubject;
//    cell.topicLabel.attributedText = [[NSAttributedString alloc]initWithString:subject];
    
    cell.authorLabel.text = author;
    cell.timeLabel.text = time;
    return cell;
}

- (NSString *)covertTimeStamp:(NSString *) timestamp {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval posttime = [timestamp longLongValue];
    NSTimeInterval time = currentTime - posttime;
    NSInteger sec = time/60;
    if (sec<60) {
        return [NSString stringWithFormat:@"%ld分钟前",sec];
    }
    
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours<24) {
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 10) {
        return [NSString stringWithFormat:@"%ld天前",days];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:posttime];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
    
}

- (NSString *)convertUnicode:(NSString *) string {
    return [string stringByRemovingPercentEncoding];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [_threadArray objectAtIndex:[indexPath row]];
    if ([self respondsToSelector:@selector(performSegueWithIdentifier:sender:)]) {
    [self performSegueWithIdentifier:@"test" sender:dict];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"test"]) {
//        NSLog(@"wrong identifer");
        BITTopicListTableViewController *topicViewController = segue.destinationViewController;
        NSDictionary *dict = (NSDictionary *)sender;
        topicViewController.tid = dict[@"tid"];
    }
 
}

@end
