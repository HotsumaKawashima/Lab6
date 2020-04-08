#include <stdlib.h>
#import <Foundation/Foundation.h>

@interface Dice : NSObject {
  NSInteger value;
  BOOL isHeld;
}

@property(nonatomic) NSInteger value;
@property(nonatomic) BOOL isHeld;

- (void)roll;
- (void)hold;
- (void)release;
- (NSString *)toString;
@end

@implementation Dice

@synthesize value;
@synthesize isHeld;

- (instancetype)init {
  self = [super init];
  if (self) {
    self.isHeld = NO;
  }
  return self;
}

- (void)roll {
  srand((unsigned)time(NULL));
  value = rand()%6 + 1;
}

- (void)hold {
  isHeld = YES;
}

- (void)release {
  isHeld = NO;
}

- (NSString *)toString {
  NSString *stringValue = [[[NSArray alloc] initWithObjects:@"⚀", @"⚁", @"⚂", @"⚃", @"⚄", @"⚅", nil] objectAtIndex: value - 1];

  if(isHeld) {
    return [NSString stringWithFormat:@"%@%@%@",@"[ ", stringValue, @" ]"];
  }
  return stringValue;
}
@end

@interface GameController : NSObject {
  NSMutableArray *dices;
  NSInteger remainingRolls;
}

@property(nonatomic, assign) NSMutableArray *dices;
@property(nonatomic, assign) NSInteger remainingRolls;

- (instancetype)init;
- (NSInteger)score;
- (void)rollDices;
- (void)holdDice: (NSInteger)index;
- (void)releaseDice: (NSInteger)index;
- (void)resetDices;
- (void)display;

@end

@implementation GameController

@synthesize dices;
@synthesize remainingRolls;

- (instancetype)init {
  self = [super init];
  if (self) {
    self.dices = [[NSMutableArray alloc] init];
    self.remainingRolls = 5;
    NSInteger i = 0;
    for (i = 0; i < 5; i++) {
      [self.dices addObject:[[Dice alloc] init]];
    }
  }
  return self;
}

- (NSInteger)score {
  NSInteger result = 0;
  for (Dice *dice in dices) {
    result += [dice value];
  }
  return result;
}

- (void)rollDices {
  remainingRolls = remainingRolls - 1;
  for (Dice *dice in dices) {
    if(!dice.isHeld) {
      [dice roll];
    }
  }
}

- (void)holdDice: (NSInteger)index {
  [[dices objectAtIndex: index] hold];
}

- (void)releaseDice: (NSInteger)index {
  [[dices objectAtIndex: index] release];
}

- (void)resetDices {
  for (Dice *dice in dices) {
    [dice release];
  }
}

- (void)display {
  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (Dice *dice in dices) {
    [array addObject:[dice toString]];
  }

  NSLog(@"Remaining Rolls: %d", remainingRolls);
  NSLog(@"-----------------------");
  NSLog(@"--   Current Dice    --");
  NSLog([array componentsJoinedByString:@" "]);
  NSLog(@"");
  NSLog(@"--    Total Score    --");
  NSLog(@"Score: %d", [self score]);
  NSLog(@"-----------------------");
}

@end

@interface InputHandler : NSObject
- (NSString *) introduce;
- (NSString *) getInput;
- (NSString *) getDiceIndex;
@end

@implementation InputHandler

- (NSString *)getInput {
  char buf[100];
  fgets(buf, 100, stdin);
  return [[NSString stringWithCString:buf encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)introduce {
  NSLog(@"'roll' to roll the dice");
  NSLog(@"'hold' to hold a dice");
  NSLog(@"'reset' to un-hold all dice");
  NSLog(@"'show' to see current dice");
  NSLog(@"'done' to end the game");
  NSLog(@"'display' to show current stats");
  return [self getInput];
}

- (NSString *)getDiceIndex {
  NSLog(@"Enter the number of the die:");
  return [self getInput];
}
@end

int main(int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  InputHandler *inputHandler = [[InputHandler alloc] init];
  GameController *gameController = [[GameController alloc] init];

  while(YES) {
    if(gameController.remainingRolls == 0) {
      break;
    }

    NSString *input = [inputHandler introduce];

    if([input isEqualToString:@"roll"]) {
      [gameController rollDices];
      [gameController display];
    } else if([input isEqualToString:@"hold"]) {
      input = [inputHandler getDiceIndex];
      [gameController holdDice: [input intValue]];
    } else if([input isEqualToString:@"reset"]) {
      [gameController resetDices];
    } else if([input isEqualToString:@"show"]) {
      [gameController display];
    } else if([input isEqualToString:@"done"]) {
      break;
    } else if([input isEqualToString:@"display"]) {
      [gameController display];
    }
  }
  NSLog(@"Your score is %d", [gameController score]);
  return 0;
}
