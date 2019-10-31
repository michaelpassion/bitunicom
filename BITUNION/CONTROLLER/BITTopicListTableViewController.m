//
//  BITTopicListTableViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2018/11/20.
//  Copyright © 2018 michael. All rights reserved.
//

#import "BITTopicListTableViewController.h"
#import "BITUserInfo.h"
#import "BITNetManager.h"
#import "BITTopicTableViewCell.h"
#import "NSString+URLEncode.h"
#import "Ono.h"
#import "NTSafariViewController.h"
#import "MJRefresh.h"
#import "UIImageView+AFNetworking.h"
#import <YYImage/YYImage.h>
#import <YYWebImage/YYWebImage.h>


@interface BITTopicListTableViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *topicArray;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, assign) NSInteger totalTid;

@end

@implementation BITTopicListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _start = 0;
    _end = 20;
    _topicArray = [[NSMutableArray alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"BITTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BITTopicTableViewCellIdentifer"];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getTopicList)];
//    [self getTopicList];
    MJRefreshAutoFooter *footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)];
    footer.triggerAutomaticallyRefreshPercent = 0.5;
    self.tableView.mj_footer = footer;
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_topicArray count];
}

- (void)getTotalFid {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session,
                                @"tid": @"*",
                                @"fid": _tid,
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_fid_tid.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSString *totalFid = response[@"tid_sum"];
            self.totalTid = [totalFid integerValue];
            [self.tableView.mj_header beginRefreshing];
            
        } else {
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}
- (void)getMore {
    if (_end < _totalTid) {
        _start = _end;
        _end = _end + 20>_totalTid?_totalTid:_end+20;
        [self getTopicList];
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}
- (void)getTopicList {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{@"action":@"post",
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session,
                                @"tid":_tid,
                                @"from":[NSString stringWithFormat:@"%ld",(long)_start],
                                @"to":[NSString stringWithFormat:@"%ld",(long)_end]
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_post.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求论坛列表成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSArray * array = response[@"postlist"];
//            NSLog(@"%@", array);
            [self.topicArray addObjectsFromArray:array];
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            
        } else {
            // session 已过期，自动重新登录，重新请求
            [BITNetManager relogin];
            [self getTopicList];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BITTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BITTopicTableViewCellIdentifer" forIndexPath:indexPath];

    NSDictionary *dict = _topicArray[indexPath.row];
//    NSLog(@"%@", dict);
    NSString *author = dict[@"author"];
    cell.authorLabel.text = [author URLDecodedString];
    NSString *floor = indexPath.row != 0 ?[NSString stringWithFormat:@"%lu 楼", (unsigned long)indexPath.row]: @"楼主";
    
    NSUInteger second = [dict[@"dateline"] integerValue];
    NSString *bar = [[NSDate dateWithTimeIntervalSince1970:second] description];
    cell.floorLevel.text = [NSString stringWithFormat:@"%@ %@", floor, bar];

    NSString *text = [dict[@"message"] URLDecodedString];
    
    NSDictionary *msgDict = [self converstString:text];
//    NSLog(@"%@", text);
    
    if ([[msgDict allKeys] count] == 0) {
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding]
                 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
                                                 }
      documentAttributes:nil
                error:nil];
        
        [message addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:[UIFont systemFontSize] * 1.25]
                        range:NSMakeRange(0, message.length)];
        cell.messageLabel.attributedText = message;
        

    } else {
        NSString *postString = msgDict[@"text"];
        NSMutableParagraphStyle *quotedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        quotedParagraphStyle.alignment = NSTextAlignmentNatural;
        quotedParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        quotedParagraphStyle.firstLineHeadIndent = 12;
        quotedParagraphStyle.headIndent = 12;
        
        NSString *quetoString = msgDict[@"queto"];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", postString, quetoString]];
       
        
        [message addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize] * 1.25] range:NSMakeRange(0, postString.length)];
        [message addAttributes:@{
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ,
                            NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]],
                NSForegroundColorAttributeName: [UIColor grayColor],
                NSParagraphStyleAttributeName: quotedParagraphStyle
                                }        range:NSMakeRange(postString.length, quetoString.length)];
        cell.messageLabel.attributedText = message;
        cell.messageLabel.ignoreCommonProperties = NO;
//TODO: 添加引用竖线，还不成熟
//        NSRange quoteRange = NSMakeRange(postString.length, quetoString.length);
//        CGRect quetoRect = [cell.messageLabel.textLayout rectForRange:[YYTextRange rangeWithRange:quoteRange]];
//        CGRect quteoBarRect = CGRectMake(quetoRect.origin.x,quetoRect.origin.y
//                                , 5, quetoRect.size.height);
//        UIView *quetoBar = [[UIView alloc] initWithFrame:quteoBarRect];
//        quetoBar.backgroundColor = [UIColor grayColor];
//        [cell.messageLabel addSubview:quetoBar];
    }
    
    // 添加图片
    NSString *attachment = [[NSString stringWithFormat:@"%@", dict[@"attachment"]] URLDecodedString];
    
    if (![attachment isEqualToString:@"<null>"] ) {
        NSUInteger num = [dict[@"attachimg"] integerValue];
        NSLog(@"%@", attachment);
        NSString *urlString = [NSString stringWithFormat:@"http://out.bitunion.org/%@", attachment];
        NSURL *url = [NSURL URLWithString:urlString];
        UIImageView *imageView = [YYAnimatedImageView new];
        [imageView yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"test.jpeg"]];
        
//        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"test.jpeg"]];
//        [imageView setFrame:CGRectMake(0, 0, 100, 100)];
//        NSString *urlString = [NSString stringWithFormat:@"http://out.bitunion.org/%@", attachment];
//        [imageView yy_setImageWithURL:[NSURL URLWithString:urlString] options:YYWebImageOptionProgressive];
//        NSURL *url = [NSURL URLWithString:urlString];
       
        [imageView setFrame:CGRectMake(0, 0, 100, 100)];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [imageView addGestureRecognizer:tap];


        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:[UIFont systemFontOfSize: 18] alignment:YYTextVerticalAlignmentCenter];
        
        NSMutableAttributedString *string = cell.messageLabel.attributedText;
        NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n\n\n"];
        [string appendAttributedString:newLine];
        
        [attachText yy_setTextHighlightRange:NSMakeRange(0, attachText.length) color:[UIColor redColor] backgroundColor:[UIColor redColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"works fine");
        }];
        [string appendAttributedString:attachText];
//
        string.yy_lineBreakMode = NSLineBreakByCharWrapping;
//        YYTextDebugOption *debugOptions = [YYTextDebugOption new];
//        debugOptions.baselineColor = [UIColor redColor];
//        debugOptions.CTFrameBorderColor = [UIColor redColor];
//        debugOptions.CTLineFillColor = [UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:0.180];
//        debugOptions.CGGlyphBorderColor = [UIColor colorWithRed:1.000 green:0.524 blue:0.000 alpha:0.200];
//        [YYTextDebugOption setSharedDebugOption:debugOptions];

        cell.messageLabel.attributedText = string;
        
        NSLog(@"%@", string);
        
    }
    cell.messageLabel.userInteractionEnabled = true;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:cell.messageLabel.attributedText];
    
    [content enumerateAttributesInRange:cell.messageLabel.attributedText.yy_rangeOfAll options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSURL *link = [attrs objectForKey:NSLinkAttributeName];
        
        if (link) {
            [content yy_setTextHighlightRange:range color:[UIColor blueColor] backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NTSafariViewController *webVC = [[NTSafariViewController alloc] initWithURL:link];
                [self presentViewController:webVC animated:YES completion:nil];
            }];
        }
        
    }];
    
    cell.messageLabel.attributedText = content;
    dict = nil;
    
    return cell;
}

-(NSDictionary *)converstString:(NSString *) htmlString {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    NSString *table = @"bgcolor=\"BORDERCOLOR\"";

    NSString *text_xpath = @"/html/body/text()";
    NSString *queto_xpath = @"/html/body/center/table/tr[2]/td/table/tr/td/text()[2]";
    NSString *queto_author = @"/html/body/center/table/tr[2]/td/table/tr/td/b";
    
    if ([htmlString rangeOfString:table].location != NSNotFound) {
        ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithString: htmlString
                                                                encoding: NSUTF8StringEncoding
                                                                   error:nil];
        ONOXMLElement *title = [document firstChildWithXPath:text_xpath];
        dict[@"text"] = [title stringValue];

        title = [document firstChildWithXPath:queto_xpath];
        dict[@"queto"] = [title stringValue];
        
        title = [document firstChildWithXPath:queto_author];
        dict[@"queto_author"] = [title stringValue];
        
    } else {
        return nil;
    }
    
    return  dict;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"Tapped cell");
}

- (void)handleTap:(UIGestureRecognizer *)tap {
    NSLog(@"Tapped Label");
}

@end
