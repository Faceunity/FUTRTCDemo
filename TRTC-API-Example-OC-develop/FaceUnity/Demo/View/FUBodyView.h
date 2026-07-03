//
//  FUBodyView.h
//  FaceUnity third-party demo (synced from FULiveDemo BodyBeauty)
//

#import <UIKit/UIKit.h>
#import "FUBodyViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUBodyView : UIView

- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUBodyViewModel *)viewModel;

@end

@interface FUBodyCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, assign) BOOL defaultInMiddle;

@property (nonatomic, assign) double currentValue;

@property (nonatomic, copy) NSString *imageName;

@end

NS_ASSUME_NONNULL_END