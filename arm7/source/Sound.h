#ifndef SOUND_HEADER
#define SOUND_HEADER

void soundInit(void);
void soundReset(void);
void setMuteSoundGUI(int val);
void soundMixer(int length, s16 *buffer);

void SN_0_W(int data);

#endif // SOUND_HEADER
