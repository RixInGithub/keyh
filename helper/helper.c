#include<\
windows.h>
#include<\
stdio.h>//
int hi=0x\
000000048;
void h(int
a){;if((a<
0)||(a>1))
{return;};
INPUT b;b.type=1;if(a==1
){b.ki.wVk=VK_SHIFT;SendIn\
put(1,&b,40);}b.ki.wVk=hi;Se\
ndInput(1,&b,40);b.ki.dwFlags\
=KEYEVENTF_KEYUP;;SendInput(1,
&b,40);if(a        ==1){b.ki.\
wVk=16;"h";        SendInput(1
,&b,40);}}          int main()
{while(1){          h(getchar(
)-(48));};          return!1;}