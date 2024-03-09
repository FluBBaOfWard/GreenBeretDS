#ifndef FILEHANDLING_HEADER
#define FILEHANDLING_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "Games/GreenBeret.h"

#define FILEEXTENSIONS ".zip"

extern int selectedGame;

int loadSettings(void);
void saveSettings(void);
int loadNVRAM(void);
void saveNVRAM(void);
void loadState(void);
void saveState(void);
bool loadGame(int gameNr);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // FILEHANDLING_HEADER
