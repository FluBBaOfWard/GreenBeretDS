#include <nds.h>

#include "Gui.h"
#include "Shared/EmuMenu.h"
#include "Shared/EmuSettings.h"
#include "Shared/FileHelper.h"
#include "Main.h"
#include "FileHandling.h"
#include "Cart.h"
#include "Gfx.h"
#include "io.h"
#include "ARMZ80/Version.h"
#include "K005849/Version.h"
#include "../arm7/source/SN76496/Version.h"

#define EMUVERSION "V0.6.2 2022-08-23"

const fptr fnMain[] = {nullUI, subUI, subUI, subUI, subUI, subUI, subUI, subUI, subUI, subUI};

const fptr fnList0[] = {uiDummy};
const fptr fnList1[] = {ui8, loadState, saveState, saveSettings, resetGame};
const fptr fnList2[] = {ui4, ui5, ui6, ui7};
const fptr fnList3[] = {uiDummy};
const fptr fnList4[] = {autoBSet, autoASet, controllerSet, swapABSet};
const fptr fnList5[] = {scalingSet, flickSet, gammaSet, bgrLayerSet, sprLayerSet};
const fptr fnList6[] = {speedSet, autoStateSet, autoSettingsSet, autoPauseGameSet, powerSaveSet, screenSwapSet, debugTextSet, sleepSet};
const fptr fnList7[] = {difficultSet, coinASet, coinBSet, livesSet, bonusSet, cabinetSet, demoSet, flipSet, uprightSet, serviceSet};
const fptr fnList8[] = {quickSelectGame, quickSelectGame, quickSelectGame, quickSelectGame};
const fptr fnList9[] = {uiDummy};
const fptr *const fnListX[] = {fnList0, fnList1, fnList2, fnList3, fnList4, fnList5, fnList6, fnList7, fnList8, fnList9};
const u8 menuXItems[] = {ARRSIZE(fnList0), ARRSIZE(fnList1), ARRSIZE(fnList2), ARRSIZE(fnList3), ARRSIZE(fnList4), ARRSIZE(fnList5), ARRSIZE(fnList6), ARRSIZE(fnList7), ARRSIZE(fnList8), ARRSIZE(fnList9)};
const fptr drawUIX[] = {uiNullNormal, uiFile, uiOptions, uiAbout, uiController, uiDisplay, uiSettings, uiDipswitches, uiLoadGame, uiDummy};
const u8 menuXBack[] = {0,0,0,0,2,2,2,2,1,8};

u8 g_gammaValue = 0;

char *const autoTxt[] = {"Off","On","With R"};
char *const speedTxt[] = {"Normal","200%","Max","50%"};
char *const sleepTxt[] = {"5min","10min","30min","Off"};
char *const brighTxt[] = {"I","II","III","IIII","IIIII"};
char *const ctrlTxt[] = {"1P","2P"};
char *const dispTxt[] = {"UNSCALED","SCALED"};
char *const flickTxt[] = {"No Flicker","Flicker"};

char *const coinTxt[] = {
	"1 Coin 1 Credit","1 Coin 2 Credits","1 Coin 3 Credits","1 Coin 4 Credits",
	"1 Coin 5 Credits","1 Coin 6 Credits","1 Coin 7 Credits","2 Coins 1 Credit",
	"2 Coins 3 Credits","2 Coins 5 Credits","3 Coins 1 Credit","3 Coins 2 Credits",
	"3 Coins 4 Credits","4 Coins 1 Credit","4 Coins 3 Credits","Free Play"};
char *const diffTxt[] = {"Easy","Normal","Hard","Very Hard"};
char *const livesTxt[] = {"2","3","5","7"};
char *const bonusTxt[] = {"30K 70K 70K+","40K 80K 80K+","50K 100K 100K+","50K 200K 200K+"};
char *const cabTxt[] = {"Cocktail","Upright"};
char *const singleTxt[] = {"Single","Dual"};


void setupGUI() {
	emuSettings = AUTOPAUSE_EMULATION;
	keysSetRepeat(25, 4);	// delay, repeat.
	openMenu();
}

/// This is called when going from emu to ui.
void enterGUI() {
}

/// This is called going from ui to emu.
void exitGUI() {
}

void quickSelectGame(void) {
	while (loadGame(selected)) {
		setSelectedMenu(9);
		if (!browseForFileType(FILEEXTENSIONS)) {
			backOutOfMenu();
			return;
		}
	}
	closeMenu();
}

void uiNullNormal() {
	uiNullDefault();
}

void uiFile() {
	setupMenu();
	drawMenuItem("Load Game");
	drawMenuItem("Load State");
	drawMenuItem("Save State");
	drawMenuItem("Save Settings");
	drawMenuItem("Reset Game");
	if (enableExit) {
		drawMenuItem("Quit Emulator");
	}
}

void uiOptions() {
	setupMenu();
	drawMenuItem("Controller");
	drawMenuItem("Display");
	drawMenuItem("Settings");
	drawMenuItem("DipSwitches");
}

void uiAbout() {
	cls(1);
	drawTabs();
	drawText(" Select: Insert coin",4,0);
	drawText(" Start:  Start button",5,0);
	drawText(" DPad:   Move character",6,0);
	drawText(" Up:     Jump/Climb",7,0);
	drawText(" Down:   Crouch",8,0);
	drawText(" B:      Knife attack",9,0);
	drawText(" A:      Special attack",10,0);

	drawText(" GreenBeretDS " EMUVERSION, 20, 0);
	drawText(" ARMZ80       " ARMZ80VERSION, 21, 0);
	drawText(" K005849      " K005849VERSION, 22, 0);
	drawText(" ARMSN76496   " ARMSN76496VERSION, 23, 0);
}

void uiController() {
	setupSubMenu(" Controller Settings");
	drawSubItem("B Autofire: ", autoTxt[autoB]);
	drawSubItem("A Autofire: ", autoTxt[autoA]);
	drawSubItem("Controller: ", ctrlTxt[(joyCfg>>29)&1]);
	drawSubItem("Swap A-B:   ", autoTxt[(joyCfg>>10)&1]);
}

void uiDisplay() {
	setupSubMenu(" Display Settings");
	drawSubItem("Display: ", dispTxt[g_scaling]);
	drawSubItem("Scaling: ", flickTxt[gFlicker]);
	drawSubItem("Gamma: ", brighTxt[g_gammaValue]);
	drawSubItem("Disable Background: ", autoTxt[gGfxMask&1]);
	drawSubItem("Disable Sprites: ", autoTxt[(gGfxMask>>4)&1]);
}

void uiSettings() {
	setupSubMenu(" Settings");
	drawSubItem("Speed: ", speedTxt[(emuSettings>>6)&3]);
	drawSubItem("Autoload State: ", autoTxt[(emuSettings>>2)&1]);
	drawSubItem("Autosave Settings: ", autoTxt[(emuSettings>>9)&1]);
	drawSubItem("Autopause Game: ", autoTxt[emuSettings&1]);
	drawSubItem("Powersave 2nd Screen: ",autoTxt[(emuSettings>>1)&1]);
	drawSubItem("Emulator on Bottom: ", autoTxt[(emuSettings>>8)&1]);
	drawSubItem("Debug Output: ", autoTxt[gDebugSet&1]);
	drawSubItem("Autosleep: ", sleepTxt[(emuSettings>>4)&3]);
}

void uiDipswitches() {
//	char s[10];
	setupSubMenu(" Dipswitch Settings");
	drawSubItem("Difficulty: ", diffTxt[(g_dipSwitch1>>5)&3]);
	drawSubItem("Coin A: ", coinTxt[g_dipSwitch0 & 0xF]);
	drawSubItem("Coin B: ", coinTxt[(g_dipSwitch0>>4) & 0xF]);
	drawSubItem("Lives: ", livesTxt[g_dipSwitch1 & 3]);
	drawSubItem("Bonus: ", bonusTxt[(g_dipSwitch1>>3)&3]);
	drawSubItem("Cabinet: ", cabTxt[(g_dipSwitch1>>2)&1]);
	drawSubItem("Demo Sound: ", autoTxt[(g_dipSwitch1>>7)&1]);
	drawSubItem("Flip Screen: ", autoTxt[g_dipSwitch2&1]);
	drawSubItem("Upright Controls: ", singleTxt[(g_dipSwitch2>>1)&1]);
	drawSubItem("Service Mode: ", autoTxt[(g_dipSwitch2>>2)&1]);

//	int2str(g_coin0, s);
//	drawSubItem("CoinCounter1:       ", s);
//	int2str(g_coin1, s);
//	drawSubItem("CoinCounter2:       ", s);
}

void uiLoadGame() {
	setupSubMenu(" Load game");
	drawMenuItem(" Green Beret");
	drawMenuItem(" Rush'n Attack (US)");
	drawMenuItem(" Green Beret (bootleg)");
	drawMenuItem(" Mr. Goemon (Japan)");
}

void nullUINormal(int key) {
	if (key & KEY_TOUCH) {
		openMenu();
	}
}

void nullUIDebug(int key) {
	if (key & KEY_TOUCH) {
		openMenu();
	}
}

void resetGame() {
	loadCart(selectedGame, 0);
}


//---------------------------------------------------------------------------------
/// Switch between Player 1 & Player 2 controls
void controllerSet() {				// See io.s: refreshEMUjoypads
	joyCfg ^= 0x20000000;
}

/// Swap A & B buttons
void swapABSet() {
	joyCfg ^= 0x400;
}

/// Turn on/off scaling
void scalingSet(){
	g_scaling ^= 0x01;
	refreshGfx();
}

/// Change gamma (brightness)
void gammaSet() {
	g_gammaValue++;
	if (g_gammaValue > 4) g_gammaValue=0;
	paletteInit(g_gammaValue);
	paletteTxAll();					// Make new palette visible
	setupMenuPalette();
}

/// Turn on/off rendering of background
void bgrLayerSet(){
	gGfxMask ^= 0x03;
}
/// Turn on/off rendering of sprites
void sprLayerSet(){
	gGfxMask ^= 0x10;
}


/// Number of coins for credits
void coinASet() {
	int i = (g_dipSwitch0+1) & 0xF;
	g_dipSwitch0 = (g_dipSwitch0 & ~0xF) | i;
}
/// Number of coins for credits
void coinBSet() {
	int i = (g_dipSwitch0+0x10) & 0xF0;
	g_dipSwitch0 = (g_dipSwitch0 & ~0xF0) | i;
}
/// Number of lifes to start with
void livesSet() {
	int i = (g_dipSwitch1+1) & 3;
	g_dipSwitch1 = (g_dipSwitch1 & ~3) | i;
}
/// At which score you get bonus lifes
void bonusSet() {
	int i = (g_dipSwitch1+8) & 0x18;
	g_dipSwitch1 = (g_dipSwitch1 & ~0x18) | i;
}
/// Game difficulty
void difficultSet() {
	int i = (g_dipSwitch1+0x20) & 0x60;
	g_dipSwitch1 = (g_dipSwitch1 & ~0x60) | i;
}
/// Cocktail/upright
void cabinetSet() {
	g_dipSwitch1 ^= 0x04;
}
/// Demo sound on/off
void demoSet() {
	g_dipSwitch1 ^= 0x80;
}
/// Flip screen
void flipSet() {
	g_dipSwitch2 ^= 0x01;
}
/// Dual or single controlls for upright set
void uprightSet() {
	g_dipSwitch2 ^= 0x02;
}
/// Test/Service mode
void serviceSet() {
	g_dipSwitch2 ^= 0x04;
}
