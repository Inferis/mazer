//
//  CommonMacros.h
//
//  Created by Tom Adriaenssen on 03/07/13.
//

typedef void(^CallbackWithRoomId)(int);
typedef void(^Callback)(void);
typedef void(^ObjectCallback)(id object);

static inline void dispatch_async_bg(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

static inline void dispatch_async_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_sync_main(dispatch_block_t block) {
    dispatch_sync(dispatch_get_main_queue(), block);
}

static inline void dispatch_delayed_main(NSTimeInterval time, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

static inline BOOL IsIPad() {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}
