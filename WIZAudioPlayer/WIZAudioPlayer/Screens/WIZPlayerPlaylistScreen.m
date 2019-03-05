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
{
    BOOL isFilter;
}

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
    
    isFilter = NO;
    
    [self.tableView setEditing:NO animated:NO];
    [self.tableView reloadData];
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

#pragma mark - move and delete

#pragma mark -MOVE-

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *inputArray = [NSMutableArray arrayWithArray:[WIZAudioDataProvider sharedInstance].playlist];
    id object = [inputArray objectAtIndex:fromIndexPath.row];
    [inputArray removeObjectAtIndex:fromIndexPath.row];
    [inputArray insertObject:object atIndex:toIndexPath.row];
    
    [[WIZAudioDataProvider sharedInstance] loadPlaylist:inputArray];
    
    [self.tableView reloadData];
}

#pragma mark -DELETE-

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRow = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSMutableArray *inputArray = [NSMutableArray arrayWithArray:[WIZAudioDataProvider sharedInstance].playlist];
        [inputArray removeObjectAtIndex:indexPath.row];
        
        [[WIZAudioDataProvider sharedInstance] loadPlaylist:inputArray];
        
        [self.tableView reloadData];
    }];
    return @[deleteRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - cancel

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - filter

- (IBAction)sortTap:(id)sender {
    isFilter = !isFilter;
    [self.tableView setEditing:isFilter animated:isFilter];
    [self.tableView reloadData];
}

@end
