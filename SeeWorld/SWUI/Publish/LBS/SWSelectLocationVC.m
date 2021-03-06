//
//  SWSelectLocationVC.m
//  SeeWorld
//
//  Created by Albert Lee on 17/11/2017.
//  Copyright © 2017 SeeWorld. All rights reserved.
//

#import "SWSelectLocationVC.h"
#import "SWSelectLocationCell.h"
#import "SWPostGetLocationAPI.h"
@interface SWSelectLocationVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)CLLocation  *location;
@property(nonatomic, strong)CLPlacemark *placemark;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSString    *lbsPostionName;
@end

@implementation SWSelectLocationVC{

}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.leftBarButtonItem = [UIBarButtonItem loadLeftBarButtonItemWithTitle:SWStringCancel
                                                                                    color:[UIColor colorWithRGBHex:0x55acef]
                                                                                     font:[UIFont systemFontOfSize:16]
                                                                                   target:self
                                                                                   action:@selector(onCancel)];
  self.view.backgroundColor = [UIColor whiteColor];
  self.navigationItem.titleView = [[ALTitleLabel alloc] initWithTitle:@"添加定位" color:[UIColor colorWithRGBHex:NAV_BAR_COLOR_HEX]];
  
  
  __weak typeof(self)wSelf = self;
  [[SWLocationManager shared] obtainCurrentLocationAndReverse:YES
                                                    isNeedPOI:NO
                                            completitionBlock:^(CLLocation *location, CLPlacemark *placemark, NSError *error) {
                                              if (!error) {
                                                wSelf.location = location;
                                                wSelf.placemark = placemark;
                                                wSelf.lbsPostionName = wSelf.placemark.locality?wSelf.placemark.locality:(wSelf.placemark.administrativeArea?wSelf.placemark.administrativeArea:wSelf.placemark.country);
                                                [wSelf.tableView reloadData];
                                                [wSelf getLocation];
                                              }
                                            } failureBlock:^{
                                              
                                            } authorityFailureBlock:^{
                                              
                                            }];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.rowHeight = 50;
  _tableView.separatorInset = UIEdgeInsetsZero;
  _tableView.separatorColor = [UIColor colorWithRGBHex:0xeaeaea];
  _tableView.tableFooterView = [ALLineView lineWithFrame:CGRectMake(0, 0, _tableView.width, 0.5) colorHex:0xeaeaea];
  [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)onCancel{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getLocation{
  SWPostGetLocationAPI *api = [[SWPostGetLocationAPI alloc] init];
  api.latitude = _location.coordinate.latitude;
  api.longitude= _location.coordinate.longitude;
  __weak typeof(self)wSelf = self;
  [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
    NSDictionary *dic = [request.responseString safeJsonDicFromJsonString];
    if ([[dic safeStringObjectForKey:@"data"] length]>0) {
      wSelf.lbsPostionName = [[[dic safeStringObjectForKey:@"data"] componentsSeparatedByString:@","] safeStringObjectAtIndex:0];
      [wSelf.tableView reloadData];
    }
  } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
    
  }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return _location?2:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *iden = @"lbs";
  SWSelectLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
  if (!cell) {
    cell = [[SWSelectLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
  }
  
  [cell refreshWithRow:indexPath.row text:_lbsPostionName];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (self.delegate && [self.delegate respondsToSelector:@selector(selectLocationVCDidReturnWithLocation:placemark:)]) {
    [self.delegate selectLocationVCDidReturnWithLocation:indexPath.row?_location:nil
                                               placemark:indexPath.row?_lbsPostionName:nil];
  }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
