//
//  detailedOrderStatusTableViewController.m
//  Supermarket_Order_01
//
//  Created by 赵磊 on 15/7/28.
//  Copyright (c) 2015年 赵磊. All rights reserved.
//

#import "detailedOrderStatusTableViewController.h"
#import "OrderAppDelegate.h"

@interface detailedOrderStatusTableViewController ()
{
//获取delegate对象，以访问manager属性
OrderAppDelegate* appDelegate;
//指定接口地址
NSString* orderDetailURL;
    NSDictionary* dict;
}
@end
/*
 OrderStatus:
 1、等待超市接单；
 2、配送中；
 3、已送达；
 4、已取消；
 5、订单完成
 */
@implementation detailedOrderStatusTableViewController

- (void)viewDidLoad {
    appDelegate = [UIApplication sharedApplication].delegate;//为了访问manager属性
    orderDetailURL = [NSString stringWithFormat:@"http://115.29.197.143:8999/v1.0/order/%@",appDelegate.orderID];//获取{oid}oid即为上一次访问后台获取NSArray的数组角标
    /*获取订单详情返回值
    {name,total,time,start_time,phone_num,address,state,goods:[{id,name,quantity,price},… ]}
     8项数据
     */
    //获取订单状态
    [appDelegate.manager GET:orderDetailURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //将服务器json数据转化成NSDictionary,赋值给orders属性
        dict = responseObject;
        NSLog(@"连接后台成功!");
//        for (int i = 0; i < [orders count]; i++) {
//            NSLog(@"%@",[NSString stringWithFormat:@"第%d个订单",i]);
//            //            NSDictionary* dict = [orders objectAtIndex:i];
//            //            NSLog(@"%@",[dict objectForKey:@"sup_name"]);
//        }
        //重新加载表格数据
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取订单信息有误: %@",error);
    }];

    //先向后台获取订单状态
    //1⃣️state:待定,默认为string
    self.OrderStatus = [dict objectForKey:@"state"];
//    self.OrderStatus = @"等待超市接单";
    self.OrderStatus = @"配送中";
//    self.OrderStatus = @"已送达";
//    self.OrderStatus = @"已取消";
//    self.OrderStatus = @"订单完成";
    self.shareBtn = [[UIBarButtonItem alloc]initWithTitle:@"share" style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
    self.callBtn = [[UIBarButtonItem alloc]initWithTitle:@"call" style:UIBarButtonItemStylePlain target:self action:@selector(call:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.callBtn,self.shareBtn,nil];
    self.app = [UIApplication sharedApplication];
    [super viewDidLoad];
    [self hideExcessLine:self.tableView];

}
//分享给好友
-(void)share:(id)sender
{
    //下载二维码
}
-(void)call:(id)sender
{
    CGFloat xWidth = self.view.bounds.size.width - 40.0f;
    CGFloat yHeight = 172.0f;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    self.poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    self.poplistview.delegate = self;
    self.poplistview.datasource = self;
    self.poplistview.listView.scrollEnabled = FALSE;
    [self.poplistview setTitle:@"拨打电话"];
    [self.poplistview show];
}
-(void)hideExcessLine:(UITableView *)tableView{
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cell0 = @"cell0";
    static NSString* cell1 = @"cell1";
    static NSString* cell2 = @"cell2";
    static NSString* cell3 = @"cell3";
    static NSString* cell4 = @"cell4";
    static NSString* cell5 = @"cell5";
//    UITableView* cell = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    //包装费\配送费
    float packPrice = 0.0;
    float sendPrice = 0.5;
    //plist模拟商品
    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"购物袋" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray* goods = dict[@"goods"];
    NSArray* goodscount = dict[@"goodscount"];
    NSArray* prices = dict[@"prices"];
    NSString* detailPath = [[NSBundle mainBundle]pathForResource:@"订单详情" ofType:@"plist"];
    NSDictionary* detailDict = [NSDictionary dictionaryWithContentsOfFile:detailPath];
    NSArray* detailKeys = detailDict[@"detailKeys"];
//    NSLog(@"%@",[detailKeys objectAtIndex:0]);
    NSArray* detailValues = detailDict[@"detailValues"];
    UITableViewCell* cell;
    //1:状态详情
    if (!section) {
        orderStatusCell* ordercell;
        ordercell = [tableView dequeueReusableCellWithIdentifier:cell0];
        if (!ordercell) {
            ordercell = [[orderStatusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell0];
        }
        //为所有btn定制事件
        
        //根据Orderstatus显示不同
        if ([self.OrderStatus isEqual:@"等待超市接单"]) {
            ordercell.checkORerrorImg.image = [UIImage imageNamed:@"check.png"];
            ordercell.orderStatusLabel.text = @"付款成功，等待超市接单";
            ordercell.preTimeLabel.text = @"预计接单时间：12:30";//后台
            ordercell.chaoShiJieDanLabel.textColor = [UIColor grayColor];
            ordercell.yiShouHuoLabel.textColor = [UIColor grayColor];
            ordercell.quXiaoDingDanBtn.hidden = NO;
            [ordercell.progress setProgress:0.33];
        }else if ([self.OrderStatus isEqual:@"配送中"]){
            ordercell.checkORerrorImg.image = [UIImage imageNamed:@"check.png"];
            ordercell.orderStatusLabel.text = @"超市已接单，提货配送中";
            ordercell.preTimeLabel.text = @"预计送达时间：12:30";//后台
            ordercell.chaoShiJieDanLabel.textColor = [UIColor orangeColor];
            ordercell.yiShouHuoLabel.textColor = [UIColor grayColor];
            ordercell.queRenShouHuoBtn.hidden = NO;
            [ordercell.queRenShouHuoBtn addTarget:self action:@selector(queRenShouHuo:) forControlEvents:UIControlEventTouchUpInside];
            ordercell.dianHuaCuiDanBtn.hidden = NO;
            ordercell.quXiaoDingDanBtn.hidden = NO;
            [ordercell.progress setProgress:0.667];
        }else if ([self.OrderStatus isEqual:@"已送达"]){
            ordercell.checkORerrorImg.image = [UIImage imageNamed:@"check.png"];
            ordercell.orderStatusLabel.text = @"您已收货，记得评价哦";
            ordercell.chaoShiJieDanLabel.textColor = [UIColor orangeColor];
            ordercell.yiShouHuoLabel.textColor = [UIColor orangeColor];
            ordercell.queRenShouHuoBtn.hidden = YES;
            ordercell.quXiaoDingDanBtn.hidden = YES;
            ordercell.dianHuaCuiDanBtn.hidden = YES;
            ordercell.preTimeLabel.hidden = YES;
            ordercell.pingJiaBtn.hidden = NO;
            [ordercell.pingJiaBtn addTarget:self action:@selector(evaluate:) forControlEvents:UIControlEventTouchUpInside];
            [ordercell.progress setProgress:1.0f];
        }else if ([self.OrderStatus isEqual:@"已取消"]){
            ordercell.checkORerrorImg.image = [UIImage imageNamed:@"error.png"];
            ordercell.checkORerrorImg.frame = CGRectMake(0.3*kWindowWidth, 30, 25, 25);
            ordercell.orderStatusLabel.text = @"订单已取消";
            ordercell.orderStatusLabel.frame = CGRectMake(0.4*kWindowWidth, 30, kWindowWidth/2, 25);
            ordercell.chaoShiJieDanLabel.hidden = YES;
            ordercell.yiShouHuoLabel.hidden = YES;
            ordercell.dingDanQuXiaoLabel.hidden = NO;
            ordercell.dingDanQuXiaoLabel.frame = CGRectMake(0.65*kWindowWidth, 125, 40, 10);
            [ordercell.dingDanQuXiaoLabel sizeToFit];
            [ordercell.progress setProgress:1.0f];
        }else{
            ordercell.checkORerrorImg.image = [UIImage imageNamed:@"check.png"];
            ordercell.orderStatusLabel.text = @"评价成功，您已完成此订单";
            ordercell.chaoShiJieDanLabel.textColor = [UIColor orangeColor];
            ordercell.yiShouHuoLabel.textColor = [UIColor orangeColor];
            ordercell.dingDanTousuBtn.hidden = NO;
            [ordercell.dingDanTousuBtn addTarget:self action:@selector(tousu:) forControlEvents:UIControlEventTouchUpInside];
            [ordercell.progress setProgress:1.0f];
        }
        return ordercell;
    }else if(section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell1];
        }
        cell.imageView.image = [UIImage imageNamed:@"shop.png"];
        cell.textLabel.text = @"世纪华联超市";//超市名称，从后台获取？
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else if(section == 2){
        //购物袋
        purchaseBagCell* purchaseCell;
        purchaseCell = [tableView dequeueReusableCellWithIdentifier:cell2];
        if (!purchaseCell) {
            purchaseCell = [[purchaseBagCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell3];
        }
        //plist模拟商品
        purchaseCell.goodsNameLabel.text = [goods objectAtIndex:row];
        purchaseCell.goodsCountLabel.text = [goodscount objectAtIndex:row];
        purchaseCell.totalPriceLabel.text = [prices objectAtIndex:row];
        return purchaseCell;
    }else if(section == 3){
        //包装配送费
        cell = [tableView dequeueReusableCellWithIdentifier:cell4];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell3];
        }
        if (!row) {
            //包装费
            cell.textLabel.text = @"包装费";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%g",packPrice];
        }
        else if (row == 1){
            cell.textLabel.text = @"配送费";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%g",sendPrice];
        }else{
            cell.textLabel.text = @"合计";
            cell.detailTextLabel.text = @"30";
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        return cell;
    }else if (section == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:cell4];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell4];
        }
        cell.textLabel.text = [detailKeys objectAtIndex:row];
        cell.detailTextLabel.text = [detailValues objectAtIndex:row];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        return cell;
    }else{
        MyEvaluateCell* cell = [tableView dequeueReusableCellWithIdentifier:cell5];
        if (!cell) {
            cell = [[MyEvaluateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell5];
        }
        cell.myEvaluateView.textColor = [UIColor grayColor];
        cell.myEvaluateView.text = @"从后台获取我的评价。";
        return cell;
    }
}
//投诉事件
-(void)tousu:(id)sender
{
    //跳到反馈界面，自带订单号
}
//点击cell1跳到超市详情界面
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //超市详情界面
}
//评价
-(void)evaluate:(id)sender
{
OrderEvaluate *evalueatController = [[OrderEvaluate alloc]init];
[self.navigationController pushViewController:evalueatController animated:YES];
//自定义返回按钮（将来换成图片）
UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"评价"  style:UIBarButtonItemStylePlain  target:self  action:nil];
self.navigationItem.backBarButtonItem = backButton;
}
//确认收货事件
-(void)queRenShouHuo:(id)sender
{
    //向后台发送数据后刷新订单状态Orderstatus
    self.OrderStatus = @"已送达";
    [self.tableView reloadData];
    //为什么还需要以下代码？该隐藏的没隐藏
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.OrderStatus isEqual:@"订单完成"]) {
        return 6;
    } else {
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1;
    if (section==2) {
        rows = 3;//看后台
    }else if(section==3){
        rows = 3;//固定
    }else if (section == 4){
        rows = 5;
        
    }
    return rows;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 15;
    if (section==2 || section==4 || section==5) {
        height = 45;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 38;
    if (!indexPath.section) {
        height = 183;
    }else if(indexPath.section == 5){
        height = 120;
    }
    return height;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    if (section==2) {
        header = @"购物袋";
    }else if(section == 4){
        header = @"订单详情";
    }else if(section == 5){
        header = @"我的评价";
    }
    return header;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSLog(@"进入超市详情页面!");
    }
}




//以下函数为实现UIPopoverListView协议
- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                    reuseIdentifier:identifier];
    
    NSInteger row = indexPath.row;
    
    if(row == 0){
        cell.textLabel.text = @"商家电话";
        cell.detailTextLabel.text = @"13720928727";//从后台获取
    }else if (row == 1){
        cell.textLabel.text = @"客服电话";
        cell.detailTextLabel.text = @"15651907759";
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

//拨号(可自动返回应用)
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    
    UIWebView* callWebView = [[UIWebView alloc]init];
    NSURL *telURL = nil;
    //使用UIWebView加载tel:开头的URL打电话，而且电话结束后回到本应用，以留住用户！！
    if(!indexPath.row){
    telURL = [NSURL URLWithString:@"tel:13720928727"];
    }else{
    telURL = [NSURL URLWithString:@"tel:15651907759"];
    }
    [callWebView loadRequest:[NSURLRequest requestWithURL:telURL]];
    [self.view addSubview:callWebView];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

@end