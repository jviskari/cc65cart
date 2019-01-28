#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>

#include <c64.h>

//Colors for rainbow demo:
const char rainbowcolors[8]={2,10,8,7,5,13,6,4};
//Scrolling message:
char scroll[40]="Wavy Demo by Harry Potter...";

static void writescreen()
{
	memset (1024,160,800);
	memset (0xD800, 1, 800);
	bzero (0xD800+40*24, 40);
}
static void scrollmsg()
{
	static unsigned char c;
	c=scroll[0];
	memmove (&scroll[0], &scroll[1], 39);
	scroll[39]=c;
	memcpy (1024+40*24,scroll, 40);
}
void main()
{
	//Temporary variables:
	static unsigned i,j; static unsigned char start=0, c;
	//Set default screen colors.
	bgcolor (1); bordercolor (2); textcolor (5);
	//Clear screen and translate scrolling message to screen
	//codes.
	clrscr(); puts (scroll);
	for (i=0; i<40; i++) scroll[i]=*((char*)0x0400+i);

	//Clear display area with reverse spaces for demo modules.
	writescreen();
//-----------------------------
// First demo: scroll rainbow left.
//-----------------------------
	while (!kbhit()){ //Run demo until key pressed.
		for (i=0;i<40; ++i) { //For each column:
			//draw vertical line in given color.
			for (j=i; j<(40*20); j+=40) {
				*((char*) 0xD800+j)=rainbowcolors[start+i&7];
			}
		}
		//Advance start color to the next of 8 rainbow colors
		//with wrar-around.
		start=start+1&7;
		//Scroll message.
		scrollmsg();
		//Pause and loop.
		for (i=0x7FF;i>0;--i);
	} cgetc(); //When key pressed, empty keyboard buffer.

//-----------------------------
// Second demo: triangular sound wave.
//-----------------------------
	//Clear screen.
	writescreen();
	//Initialize variables.
	i=0; start=10; c=-1;
	//Loop until key pressed.
	while (!kbhit()) {
		//If at right of screen, scroll left and clear last column.
		if (i==39) {
			memmove (0xD800, 0xD801, 40*20-1);
			for (j=i; j<20*40; j+=40) *((char*)0xD800+j)=1;
		}
		//Otherwise, move to next column.
		else ++i;
		//If at to or bottom of screen, reverse direction in c
		//and draw vertical line between middle and crest.
		//(c is added to current line # per loop and is -1 when
		//scrolling up or 1 f down.
		if (start==0){
			c=1;
			for (j=i; j<10*40; j+=40) *((char*)0xD800+j)=2;
		}
		if (start==19){
			c=-1;
			for (j=10*40+i; j<20*40; j+=40) *((char*)0xD800+j)=2;
		}
		//Make middle green.
		*((char*)0xD800+10*40+i)=5;
		//Make current pos. black.
		*((char*) (0xD800+40*start+i))=0;
		//Scroll message.
		scrollmsg();
		//Advance wave sample.
		start+=c;
		//Pause and loop.
		for (j=0x9FF;j>0;--j);
	} cgetc();
}
