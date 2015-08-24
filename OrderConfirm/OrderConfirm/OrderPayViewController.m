//
//  OrderPayViewController.m
//  OrderConfirm
//
//  Created by 赵磊 on 15/7/26.
//  Copyright (c) 2015年 赵磊. All rights reserved.
//

#import "OrderPayViewController.h"
#import "Header.h"
#import "ConfirmAppDelegate.h"

@interface OrderPayViewController ()
{
    ConfirmAppDelegate* delegate;
    NSString* couponsURL;
    NSString* myBalanceURL;//账户余额
    NSArray* couponsArray;
}
@end

@implementation OrderPayViewController
@synthesize couponCount;
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    delegate = [UIApplication sharedApplication].delegate;
    couponsURL = @"http://115.29.197.143:8999/v1.0/coupons";
    myBalanceURL = @"http://115.29.197.143:8999/v1.0/user";
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight-137) style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self hideExcessLine:self.table];
    [self.view addSubview:self.table];
    self.lastIndexPath = nil;
    
    //自定义返回按钮及事件,将来换成图片
    UIBarButtonItem* customBackBatButton = [[UIBarButtonItem alloc]initWithTitle:@"< 订单支付" style:UIBarButtonItemStylePlain target:self action:@selector(returnToOrderConfirm:)];
    self.navigationItem.leftBarButtonItem = customBackBatButton;
    
    //btn将来换成图片,btn处理有三步：
    //1⃣️btn type
    self.confirmPayBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //2⃣️btn 位置
    self.confirmPayBtn.frame = CGRectMake(3, 500, kWindowWidth-6, 36);
    //3⃣️btn title
    [self.confirmPayBtn setTitle:@"确认支付" forState:UIControlStateNormal];
    //4⃣️btn 事件
//    [self.confirmPayBtn addTarget:self action:@selector(toPay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmPayBtn];
}

//自定义左边返回按钮事件
-(void)returnToOrderConfirm:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"是否放弃付款?" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //点击“是”放弃付款返回上一页面
    if (buttonIndex) {
        [self.navigationController popViewControllerAnimated:self];
    }
}

-(void)hideExcessLine:(UITableView *)tableView{
    
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cell0 = @"cell0";
    static NSString* cell1 = @"cell1";
    UITableViewCell* cell;
    NSInteger rowNo = indexPath.row;
    //plist模拟支付
    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"订单支付" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray* left = dict[@"payleft"];
    if (!indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:cell0];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell0];
            if (!rowNo) {
                //订单总价
                cell.textLabel.text = [left objectAtIndex:rowNo];
                CGFloat totalprice = [delegate.viewController.totalgoodsPrice floatValue];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%g 元",totalprice];
            }else if (rowNo == 2){
                //我的余额
                cell.textLabel.text = [left objectAtIndex:1];
                //从后台获取账户余额
                //u_id,authority,balance,phone_num
                [delegate.manager GET:myBalanceURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"获取我的信息成功!余额:%@",[responseObject objectForKey:@"balance"]);
                    NSDictionary* mydic = responseObject;
                    self.banlance = [[mydic objectForKey:@"balance"]floatValue];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%g 元",self.banlance];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"获取账户余额失败!%@",error);
                }];
            }else if (rowNo == 3){
                //还需支付
                //需要判断是不是首次下单!!!!!!!!
                cell.textLabel.text = [left objectAtIndex:2];
                self.toPayValue = [delegate.viewController.totalgoodsPrice floatValue] - couponCount - self.banlance;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%g 元",self.toPayValue];
            }else if (rowNo ==1){
                //优惠券
                //此栏还有诸多问题
                cell.textLabel.text = @"我的购物券";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.couponCell = cell;
            }
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell1];
            if (!rowNo) {
                cell.imageView.image = [UIImage imageNamed:@"zhifubao.png"];
                cell.textLabel.text = @"支付宝支付";
                cell.detailTextLabel.text = @"推荐有支付宝账户的用户使用";
//                //设置复选框
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.imageView.image = [UIImage imageNamed:@"weixin.png"];
                cell.textLabel.text = @"微信支付";
                cell.detailTextLabel.text = @"推荐安装微信5.0及以上版本的用户使用";
                //复选框
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (!section) {
        num = 4;
    }
    else{
        num = 2;
    }
    return num;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (section == 1){
        height = 55;
    }
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 53;
    if (indexPath.section) {
        height = 72;
    }
    return  height;
}
-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = nil;
    if (section == 1) {
        header = @"选择支付方式";
    }
    return header;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //section0:row1被点击后选择购物券
    if (!indexPath.section) {
        if(indexPath.row == 1){
        ZSYPopoverListView *listView = [[ZSYPopoverListView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        listView.titleName.text = @"选择优惠券";
        listView.datasource = self;
        listView.delegate = self;
        self.couponCount = 0;//选择购物券前购物券先清零
        self.couponCell.textLabel.text = @"我的购物券";
        [listView show];
        }
    }
    //section1:选择支付方式
    else{
        UITableViewCell *cell = [self.table cellForRowAtIndexPath: indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if (self.lastIndexPath != nil && self.lastIndexPath != indexPath) {
            UITableViewCell* lastCell = [self.table cellForRowAtIndexPath:self.lastIndexPath];
            if (lastCell.accessoryType == UITableViewCellAccessoryCheckmark) {
                lastCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        self.lastIndexPath = indexPath;
    }
}
- (NSInteger)popoverListView:(ZSYPopoverListView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     问题：为什么这个函数执行了3次？？？？？？？?????????????????????????????????????????????????????
     */
    
    //后台get数据
    //[{id,price,state,timelimit}]
    [delegate.manager GET:couponsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取购物券成功!购物券张数:%lu",(unsigned long)[responseObject count]);
        couponsArray = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取购物券失败!%@",error);
    }];
    return [couponsArray count];
}
/*
 
 优惠券选择栏
 
 */
- (UITableViewCell *)popoverListView:(ZSYPopoverListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusablePopoverCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.textLabel.text = [NSString stringWithFormat:@"-dsds---%ld------", (long)indexPath.row];
    //模拟优惠券－－－－从后台获取，此处三张图片模拟012元
//        cell.imageView.image = [UIImage imageNamed:@"zhifubao.png"];
//        cell.textLabel.text = @"有效期至2015-07-24";
    for (int i = 0; i<[couponsArray count]; i++) {
        NSDictionary* dic = [couponsArray objectAtIndex:i];
        cell.textLabel.text = [dic objectForKey:@"price"];//显示购物券面额
        //先要判断购物券state，此处暂时不知道state是怎么表示的
        cell.detailTextLabel.text = [NSString stringWithFormat:@"有效期至%@",[dic objectForKey:@"timelimit"]];
    }
    return cell;
}
- (void)popoverListView:(ZSYPopoverListView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView popoverCellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        NSLog(@"select:%ld", (long)indexPath.row);//模拟选中优惠券,012元
        NSDictionary* dict = [couponsArray objectAtIndex:indexPath.row];//默认购物券顺序是按返回顺序排的
        self.couponCount += (NSInteger)[dict objectForKey:@"price"];//默认price为integer
    } else {
        //已被选的再点击则放弃
        cell.accessoryType = UITableViewCellAccessoryNone;
//        NSLog(@"diselect:%ld",(long)indexPath.row);//模拟放弃选中优惠券
        NSDictionary* dict = [couponsArray objectAtIndex:indexPath.row];
        self.couponCount -= (NSInteger)[dict objectForKey:@"price"];
    }
    if (self.couponCount) {
        self.couponCell.textLabel.text = [NSString stringWithFormat:@"%ld元购物券",(long)self.couponCount];
    }else{
        self.couponCell.textLabel.text = @"我的购物券";
    }
}
//去付款
//-(void)toPay:(id)sender
//{
//    UIAlertView* payAlertView = [UIAlertView alloc]initWithTitle:@"" message:<#(NSString *)#> delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil
//}
@end
