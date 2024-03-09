#ifndef GREENBERET_HEADER
#define GREENBERET_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "../Shared/ArcadeRoms.h"

#define GB_GAME_COUNT (4)

extern const ArcadeRom gberetRoms[14];
extern const ArcadeRom rushatckRoms[14];
extern const ArcadeRom gberetbRoms[13];
extern const ArcadeRom mrgoemonRoms[11];

extern const ArcadeGame gberetGames[GB_GAME_COUNT];

/// This runs all save state functions for each chip.
int packState(void *statePtr);

/// This runs all load state functions for each chip.
void unpackState(const void *statePtr);

/// Gets the total state size in bytes.
int getStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // GREENBERET_HEADER
