//
//  WIZPlayerPlaylistScreen.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 31/01/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZPlayerPlaylistScreen.h"
#import "CellsAndViews/WIZTrackCell.h"
#import "../Resources/WIZAudioDataProvider.h"

@interface WIZPlayerPlaylistScreen ()

@end

@implementation WIZPlayerPlaylistScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"WIZTrackCell" bundle:nil] forCellReuseIdentifier:@"trackCell"];
    
    CGFloat red   = 248/255.0;
    CGFloat green = 212/255.0;
    CGFloat blu   = 182/255.0;
 
    UIColor *bgColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    self.view.backgroundColor = bgColor;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [WIZAudioDataProvider sharedInstance].playlist.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WIZTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
    
    cell.track = [WIZAudioDataProvider sharedInstance].playlist[indexPath.row];
    // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectTrack) {
        _selectTrack([WIZAudioDataProvider sharedInstance].playlist[indexPath.row]);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - cancel

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
