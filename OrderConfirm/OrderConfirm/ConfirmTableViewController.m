//
//  ConfirmTableViewController.m
//  OrderConfirm
//
//  Created by 赵磊 on 15/7/25.
//  Copyright (c) 2015年 赵磊. All rights reserved.
//

#import "ConfirmTableViewController.h"
#import "AddressInfoCell.h"
#import "RemarkCell.h"
#import "Header.h"
#import "OrderPayViewController.h"
#import "ConfirmAppDelegate.h"
#import "purchaseBagCell.h"

@interface ConfirmTableViewController ()
{
    ConfirmAppDelegate *delegate;
    NSString* orderCreateURL;
    NSString* start_time;//起送时间
    NSString* remark;//备注
    RemarkCell* remarkCell;
    int goodcount;
    float totalprice;
    float packPrice;
    float sendPrice;
}

@end

@implementation ConfirmTableViewController
int goodscount[] = {1,2,3};//商品数量，实际从上一界面获取
float prices[] = {10.1,10.2,10.3};//商品单价，实际从上一界面获取
-(void)viewDidLoad
{
    //初始默认值
    sendPrice = 0.5;
    packPrice = 0.0;
    goodcount = 0;
    totalprice = packPrice + sendPrice;
    remark = @"备注";
    start_time = @"现在送出";
    
    [super viewDidLoad];
    
    delegate = [UIApplication sharedApplication].delegate;
    orderCreateURL = @"http://115.29.197.143:8999/v1.0/order";
    /*
     post参数
     {adr_id,start_time,remark,cou_id，sup_id,
     goods:[{gid,quantity},…]}
     */
    for (int i = 0; i < sizeof(goodscount)/sizeof(goodscount[0]); i++) {
        goodcount += goodscount[i];
        totalprice += prices[i];
    }
    self.totalgoodsPrice = [NSNumber numberWithFloat:totalprice];//向支付界面传值总价
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight-45)];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self hideExcessLine:self.table];
    self.table.dataSource = self;
    self.table.delegate = self;
    
    //关于toolbar
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,kWindowHeight-45,kWindowWidth, 45)];
    self.toolbar.backgroundColor = [UIColor grayColor];
    self.goodsCount = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, kWindowWidth/4, 45)];
    self.goodsCount.text = [NSString stringWithFormat:@"%d  份",goodcount];
    self.totalPrice = [[UILabel alloc]initWithFrame:CGRectMake(10+kWindowWidth/4, 0, kWindowWidth/4, 45)];
    self.totalPrice.text = [NSString stringWithFormat:@"￥ %g",totalprice];
    
    UIBarButtonItem* bn1 = [[UIBarButtonItem alloc]initWithCustomView:self.goodsCount];
    UIBarButtonItem* bn2 = [[UIBarButtonItem alloc]initWithCustomView:self.totalPrice];
    
    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* bn4 = [[UIBarButtonItem alloc]initWithTitle:@"去下单" style:UIBarButtonItemStylePlain target:self action:@selector(clicked:)];
    
    self.toolbar.items = [NSArray arrayWithObjects:bn1,bn2,flexItem,bn4,nil];

    [self.view addSubview:self.table];
    [self.view addSubview:self.toolbar];
    
}
-(void)hideExcessLine:(UITableView *)tableView{
    
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightForHeader = 15;
    switch (section) {
        case 3:
            heightForHeader = 45;
            break;
        default:
            heightForHeader = 15;
            break;
    }
    return heightForHeader;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1;
    // Return the number of rows in the section.
    switch (section) {
        case 3:
            rows = 3;//需看后台数据，即用户购买商品数量
            break;
        case 4:
            rows = 2;
            break;
        default:
            rows = 1;
            break;
    }
    return  rows;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* headerForSection3 = @"购物袋";
    if (section == 3) {
        return headerForSection3;
    }
    else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cell0 = @"cell0";
    static NSString* cell1 = @"cell1";
    static NSString* cell2 = @"cell2";
    static NSString* cell3 = @"cell3";
    static NSString* cell4 = @"cell4";
    UITableViewCell *cell;
    NSInteger rowNo = indexPath.row;
    //包装费\配送费

    //plist模拟商品
    /*
     以下均为本地模拟，实际从上一界面获取
     */
    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"购物袋" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray* goods = dict[@"goods"];
    
    if (indexPath.section == 0) {
        //收货地址及电话
        cell = [tableView dequeueReusableCellWithIdentifier:cell0];
        if (!cell) {
            cell = [[AddressInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell0];
        }
        return  cell;
    }
    else if (indexPath.section == 1){
        //起送时间
        cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell1];
            cell.textLabel.text = @"起送时间";//名称应和plistname相同
            cell.detailTextLabel.text = @"现在送出";
        }
        return cell;
    }
    else if (indexPath.section == 2){
        //备注
        remarkCell = [tableView dequeueReusableCellWithIdentifier:cell2];
        if (!remarkCell) {
            remarkCell = [[RemarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell2];
        }
        return remarkCell;
    }
    else if(indexPath.section == 3){
        //购物袋
        purchaseBagCell* purchaseCell;
        purchaseCell = [tableView dequeueReusableCellWithIdentifier:cell3];
        if (!purchaseCell) {
            purchaseCell = [[purchaseBagCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell3];
        }
        //plist模拟商品,实际要从上一界面获取
        purchaseCell.goodsNameLabel.text = [goods objectAtIndex:rowNo];
        purchaseCell.goodsCountLabel.text = [NSString stringWithFormat:@"%d",goodscount[rowNo]];
        purchaseCell.totalPriceLabel.text = [NSString stringWithFormat:@"%g",prices[rowNo]];
        return purchaseCell;
    }
    else{
        //包装配送费
        cell = [tableView dequeueReusableCellWithIdentifier:cell4];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell4];
        }
        if (!rowNo) {
            //包装费
            cell.textLabel.text = @"包装费";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%g",packPrice];
        }
        if (rowNo == 1){
            cell.textLabel.text = @"配送费";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%g",sendPrice];
        }
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
            height = 75.0;
            break;
        case 1:
            height = 38;
            break;
        case 2:
            height = 38;
            break;
        default:
            height = 40.5;
            break;
    }
    return height;
}
//tableViewCell点击事件设定
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //section1点击时弹出ZHPicker
    if (indexPath.section == 1) {
        _indexPath=indexPath;
        [_pickview remove];
        UITableViewCell * cell=[self.table cellForRowAtIndexPath:indexPath];//获取当前cell,为其制定picker
        _pickview=[[ZHPickView alloc] initPickviewWithPlistName:cell.textLabel.text isHaveNavControler:NO];
        _pickview.delegate=self;
        [_pickview show];
    }
}
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    UITableViewCell* cell=[self.table cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text=resultString;
    start_time = resultString;
}
//点击“去下单”按钮,先向后台创建order，再跳转到支付界面
-(void)clicked:(id)sender
{
    //1⃣️创建order给后台
    /*
     post参数
     {adr_id,start_time,remark,cou_id，sup_id,
     goods:[{gid,quantity},…]}
     */
    NSNumber* adr_id = [NSNumber numberWithInt:0];//跳转到“我的地址”界面后进行选择的地址
    NSNumber* cou_id = [NSNumber numberWithInt:0];//我拥有的该超市的coupon
    remark = remarkCell.remarkField.text;
    NSNumber* sup_id = [NSNumber numberWithInt:2];//现有超市id=2,需从上一界面获取
    /*
     此处模拟三种商品，具体整合时参考前一界面
     */
    
    NSNumber* num1 = [NSNumber numberWithInt:1];
    NSNumber* num2 = [NSNumber numberWithInt:2];
    NSNumber* num3 = [NSNumber numberWithInt:3];

    NSDictionary* good0 = @{@"gid":num1,@"quantity":num1};
    NSDictionary* good1 = @{@"gid":num2,@"quantity":num2};
    NSDictionary* good2 = @{@"gid":num3,@"quantity":num3};
    
    NSArray* goods = @[good0,good1,good2];
    
    NSDictionary* param = @{@"adr_id":adr_id,@"start_time":start_time,@"remark":remark,@"cou_id":cou_id,@"sup_id":sup_id,@"goods":goods};
    [delegate.manager POST:orderCreateURL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"创建订单成功!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"创建订单失败：%@",error);
    }];
    //跳转到支付界面
    delegate.payViewController = [[OrderPayViewController alloc]init];
    [self.navigationController pushViewController:delegate.payViewController animated:YES];
//    //自定义返回按钮（将来换成图片）
    //由于bakcBarButton事件不可自定义，此处弃用
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"订单支付"  style:UIBarButtonItemStylePlain  target:self  action:nil];//backBarbutton不可自定义事件
//    self.navigationItem.backBarButtonItem = backButton;
}
@end