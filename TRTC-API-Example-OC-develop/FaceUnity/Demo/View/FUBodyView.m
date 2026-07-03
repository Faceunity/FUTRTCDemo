//
//  FUBodyView.m
//  FaceUnity third-party demo (synced from FULiveDemo BodyBeauty)
//

#import "FUBodyView.h"
#import "FUBodyModel.h"
#import "FUSquareButton.h"
#import "FUSlider.h"
#import "FUAlertManager.h"
#import "FUDefines.h"

static NSString * const kFUBodyCellIdentifier = @"FUBodyCell";

@interface FUBodyView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
/// 程度调节
@property (nonatomic, strong) FUSlider *slider;
/// 恢复按钮
@property (nonatomic, strong) FUSquareButton *recoverButton;

@property (nonatomic, strong) FUBodyViewModel *viewModel;

@end

@implementation FUBodyView

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame viewModel:[[FUBodyViewModel alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUBodyViewModel *)viewModel {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewModel = viewModel;
        [self configureUI];
        [self refreshSubviews];
    }
    return self;
}

#pragma mark - UI

- (void)configureUI {
UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self addSubview:effectView];
    
    [self addSubview:self.slider];
    [self addSubview:self.recoverButton];
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:17.0];    [self addConstraint:constraint1];    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:55.0];    [self addConstraint:constraint2];    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44.0];    [self.recoverButton addConstraint:constraint3];    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:74.0];    [self.recoverButton addConstraint:constraint4];
    
    // 分割线
    UIView *verticalLine = [[UIView alloc] init];
    verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
    verticalLine.backgroundColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:0.2];
    [self addSubview:verticalLine];
        NSLayoutConstraint *constraint5 = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.recoverButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:14.0];    [self addConstraint:constraint5];    NSLayoutConstraint *constraint6 = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.recoverButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-15.0];    [self addConstraint:constraint6];    NSLayoutConstraint *constraint7 = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1.0];    [verticalLine addConstraint:constraint7];    NSLayoutConstraint *constraint8 = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24.0];    [verticalLine addConstraint:constraint8];
    
    [self addSubview:self.collectionView];
        NSLayoutConstraint *constraint9 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:76.0];    [self addConstraint:constraint9];    NSLayoutConstraint *constraint10 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];    [self addConstraint:constraint10];    NSLayoutConstraint *constraint11 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:43.0];    [self addConstraint:constraint11];    NSLayoutConstraint *constraint12 = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:98.0];    [self.collectionView addConstraint:constraint12];
}

- (void)refreshSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.isDefaultValue) {
            self.recoverButton.alpha = 0.6;
            self.recoverButton.userInteractionEnabled = NO;
        } else {
            self.recoverButton.alpha = 1;
            self.recoverButton.userInteractionEnabled = YES;
        }
        if (!self.slider.hidden && self.viewModel.selectedIndex >= 0) {
            self.slider.bidirection = self.viewModel.bodies[self.viewModel.selectedIndex].defaultValueInMiddle;
            self.slider.value = self.viewModel.bodies[self.viewModel.selectedIndex].currentValue;
        }
        [self.collectionView reloadData];
        if (self.viewModel.selectedIndex >= 0) {
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewModel.selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    });
}

#pragma mark - Event response

- (void)recoverAction {
    [FUAlertManager showAlertWithTitle:nil message:FULocalizedString(@"是否将所有参数恢复到默认值") cancel:FULocalizedString(@"取消") confirm:FULocalizedString(@"确定") inController:nil confirmHandler:^{
        [self.viewModel recoverAllBodyValuesToDefault];
        [self refreshSubviews];
    } cancelHandler:nil];
}

- (void)sliderValueChanged {
    [self.viewModel setBodyValue:self.slider.value];
}

- (void)sliderChangeEnded {
    [self refreshSubviews];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.bodies.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FUBodyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFUBodyCellIdentifier forIndexPath:indexPath];
    FUBodyModel *model = self.viewModel.bodies[indexPath.item];
    cell.textLabel.text = FULocalizedString(model.name);
    cell.imageName = model.name;
    cell.defaultInMiddle = model.defaultValueInMiddle;
    cell.currentValue = model.currentValue;
    cell.selected = indexPath.item == self.viewModel.selectedIndex;
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.viewModel.selectedIndex) {
        return;
    }
    self.viewModel.selectedIndex = indexPath.item;
    FUBodyModel *bodyBeauty = self.viewModel.bodies[indexPath.item];
    if (self.slider.hidden) {
        self.slider.hidden = NO;
    }
    self.slider.bidirection = bodyBeauty.defaultValueInMiddle;
    self.slider.value = bodyBeauty.currentValue;
}

#pragma mark - Getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(44, 74);
        layout.minimumLineSpacing = 22;
        layout.minimumInteritemSpacing = 22;
        layout.sectionInset = UIEdgeInsetsMake(6, 16, 6, 16);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[FUBodyCell class] forCellWithReuseIdentifier:kFUBodyCellIdentifier];
    }
    return _collectionView;
}

- (FUSquareButton *)recoverButton {
    if (!_recoverButton) {
        _recoverButton = [[FUSquareButton alloc] initWithFrame:CGRectMake(0, 0, 44, 74)];
        [_recoverButton setTitle:FULocalizedString(@"恢复") forState:UIControlStateNormal];
        [_recoverButton setImage:[UIImage imageNamed:@"recover"] forState:UIControlStateNormal];
        _recoverButton.alpha = 0.6;
        _recoverButton.userInteractionEnabled = NO;
        [_recoverButton addTarget:self action:@selector(recoverAction) forControlEvents:UIControlEventTouchUpInside];
        _recoverButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _recoverButton;
}

-(FUSlider *)slider {
    if (!_slider) {
        _slider = [[FUSlider alloc] initWithFrame:CGRectMake(56, 16, CGRectGetWidth(self.frame) - 116, FUFunctionSliderHeight)];
        _slider.hidden = YES;
        [_slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderChangeEnded) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    return _slider;
}

@end

@interface FUBodyCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation FUBodyCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        NSLayoutConstraint *imageTop = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *imageLeading = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *imageTrailing = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [self.contentView addConstraints:@[imageTop, imageLeading, imageTrailing]];
        [self.imageView addConstraint:imageHeight];
        
        [self.contentView addSubview:self.textLabel];
        NSLayoutConstraint *textTop = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:7];
        
        NSLayoutConstraint *textCenterX = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.contentView addConstraints:@[textTop, textCenterX]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    BOOL changed = NO;
    if (self.defaultInMiddle) {
        changed = fabs(self.currentValue - 0.5) > 0.01;
    }else{
        changed = self.currentValue > 0.01;
    }
    if (selected) {
        self.imageView.image = changed ? [UIImage imageNamed:[NSString stringWithFormat:@"%@-3", self.imageName]] : [UIImage imageNamed:[NSString stringWithFormat:@"%@-2", self.imageName]];
        self.textLabel.textColor = [UIColor colorWithRed:94/255.f green:199/255.f blue:254/255.f alpha:1];
    } else {
        self.imageView.image = changed ? [UIImage imageNamed:[NSString stringWithFormat:@"%@-1", self.imageName]] : [UIImage imageNamed:[NSString stringWithFormat:@"%@-0", self.imageName]];
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textLabel;
}

@end
