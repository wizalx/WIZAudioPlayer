//
//  WIZEffectTable.m
//  WIZAudioPlayer
//
//  Created by a.vorozhishchev on 13/02/2019.
//  Copyright © 2019 slamComp. All rights reserved.
//

#import "WIZEffectTable.h"
#import <AVFoundation/AVFoundation.h>

#import "CellsAndViews/WIZSliderCell.h"
#import "CellsAndViews/WIZSwitchCell.h"
#import "../Resources/WIZAudioDataProvider.h"
#import "../Resources/WIZPlayerEssentials.h"

@interface WIZEffectTable ()
{
    NSArray *headerTitles;
    NSArray *filterTitles;
}

@property (nonatomic) NSMutableArray <WIZEQFilterParameters*> *audioFiltres;

@end

@implementation WIZEffectTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WIZSliderCell" bundle:nil] forCellReuseIdentifier:@"sliderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WIZSwitchCell" bundle:nil] forCellReuseIdentifier:@"switchCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGFloat red   = 248/255.0;
    CGFloat green = 212/255.0;
    CGFloat blu   = 182/255.0;
    
    UIColor *bgColor = [UIColor colorWithRed:red green:green blue:blu alpha:1.0];
    self.view.backgroundColor = bgColor;
    
    self.audioFiltres = [NSMutableArray arrayWithCapacity:11];
    for (int i=0; i<11; i++) {
        WIZEQFilterParameters *filter = [[WIZEQFilterParameters alloc] init];
        [self.audioFiltres addObject:filter];
    }
    
    [self prepareTable];
}

-(void)prepareTable
{
    headerTitles = [NSArray arrayWithObjects:@"Parametric", @"Low Pass", @"High Pass", @"Resonant Low Pass", @"Resonant High Pass", @"Band Pass", @"Band Stop", @"Low Shelf", @"Hifh Shelf", @"Resonant Low Shelf", @"Resonant High Shelf", nil];
    
    filterTitles = [NSArray arrayWithObjects:@"Frequence", @"Bandwidth", @"Gain", nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return headerTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filterTitles.count+1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return headerTitles[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < filterTitles.count) {
        WIZSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell" forIndexPath:indexPath];
        
        cell.titleText = filterTitles[indexPath.row];
        
        WIZFilterValue *filterVal = [self createSliderValueFromRow:indexPath.row];
        [cell setValuesFromSliderMin:filterVal.minimumVal Max:filterVal.maximumVal Current:filterVal.currentVal];
        
        cell.enabled = [self enableSliderFromIndexPath:indexPath];
        
        cell.changeValue = ^(float value) {
            switch (indexPath.row) {
                case 0:
                    self.audioFiltres[indexPath.section].frequency = value;
                    break;
                case 1:
                    self.audioFiltres[indexPath.section].bandwidth = value;
                    break;
                case 2:
                    self.audioFiltres[indexPath.section].gain = value;
                    break;
                default:
                    break;
            }
            [[WIZAudioDataProvider sharedInstance] changeFilter:indexPath.section frequency:self.audioFiltres[indexPath.section].frequency bandwidth:self.audioFiltres[indexPath.section].bandwidth gain:self.audioFiltres[indexPath.section].gain bypass:self.audioFiltres[indexPath.section].bypass];
        };
        
        return cell;
    } else {
        WIZSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell" forIndexPath:indexPath];
        
        cell.titleText = @"byPass";
        
        cell.changeValue = ^(BOOL isON) {
            self.audioFiltres[indexPath.section].bypass = isON;
            [[WIZAudioDataProvider sharedInstance] changeFilter:indexPath.section frequency:self.audioFiltres[indexPath.section].frequency bandwidth:self.audioFiltres[indexPath.section].bandwidth gain:self.audioFiltres[indexPath.section].gain bypass:self.audioFiltres[indexPath.section].bypass];
        };
        
        return cell;
    }
}

- (IBAction)cancelTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - create sliders value

-(WIZFilterValue*)createSliderValueFromRow:(NSInteger)row
{
    WIZFilterValue *filterValue;
            switch (row) {
                case 0: // frequency
                    filterValue = [[WIZFilterValue alloc] initFromMinimum:20 maximum:10000 current:20];
                    break;
                case 1: // bandwidth
                    filterValue = [[WIZFilterValue alloc] initFromMinimum:0.05 maximum:5 current:0.05];
                    break;
                case 2: //gain
                    filterValue = [[WIZFilterValue alloc] initFromMinimum:-96 maximum:24 current:0];
                    break;
                default:
                    filterValue = [[WIZFilterValue alloc] initFromMinimum:-100 maximum:100 current:0];
                    break;
            }


    return filterValue;
}

#pragma mark - enabled slider

-(BOOL)enableSliderFromIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case AVAudioUnitEQFilterTypeParametric:
        case AVAudioUnitEQFilterTypeResonantLowShelf:
        case AVAudioUnitEQFilterTypeResonantHighShelf:
            return YES;
            break;
        case AVAudioUnitEQFilterTypeLowPass:
        case AVAudioUnitEQFilterTypeHighPass:
            if (indexPath.row == 0)
                return YES;
            break;
        case AVAudioUnitEQFilterTypeResonantLowPass:
        case AVAudioUnitEQFilterTypeResonantHighPass:
        case AVAudioUnitEQFilterTypeBandPass:
        case AVAudioUnitEQFilterTypeBandStop:
            if (indexPath.row != 2)
                return YES;
            break;
        case AVAudioUnitEQFilterTypeLowShelf:
        case AVAudioUnitEQFilterTypeHighShelf:
            if (indexPath.row != 1)
                return YES;
        default:
            break;
    }
    return NO;
}

@end
