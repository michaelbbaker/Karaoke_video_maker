/*
will need to do threading for top and bottom screen letters
will need to do arraylist for each timing event(?)
 */

String[] lines;                     //array to hold loaded file (split by line)
String songName;
String sungBy;
String top;                         //words to put on top line
String bot;                         //words to put on bot line
  
int lineNum = 0;                  //current numerical index of line in file
int phraseNum = 0;                //current numerical index of phrase in line
int charNum = 0;                  //current numerical index of char in phrase
int writeIndex = 0;               //the numerical index of the next line to write to screen

int[] titleScreenTimes = {0,0};
int[] topLineTimes = {0,0};         //start,end for top
int[] botLineTimes = {0,0};         //start,end for bot
int[] screenDims = {512,192};      //screen Dimensions //512,192
float[] singPos = {0, 0};            //current onscreen write position    

boolean botActive = false;      //if there is stuff onscreen for bot
boolean topActive = false;      //if there is stuff onscreen for top
boolean writeTop  = true;       //the line to write to currently is top (is bottom if false)
boolean singTop   = true;       //the line to sing currently
boolean charSung  = true;       //
boolean topClear  = true;
boolean botClear  = true;

int timer;                      //elapsed time 
int loadTime;                   //time to setup
int topY = 50;                  //Y value for top line
int botY = 150;                 //Y value for bot line
float topX;                     //X origin value for next top line
float botX;                     //X origin value for next bot line
int singTime;                   //time to sing current letter


color bg = color(0,255,255);
color toSing = color(255,0,0);
color sung = color(255,255,0);

SongLine currentLine;          //current line in file
SongPhrase currentPhrase;      //current phrase in file
char currentChar;              //current char in file

ArrayList<SongLine> song; 
PFont f;
PGraphics t;                   //text
PGraphics b;                   //background
PGraphics s;                   //scan/sing

void setup() {
  f = createFont("Gotham Bold",25,true);
  textFont(f);
  
  t=createGraphics(screenDims[0],screenDims[1], JAVA2D);
  b=createGraphics(screenDims[0],screenDims[1], JAVA2D);
  s=createGraphics(screenDims[0],screenDims[1], JAVA2D);
  
  size(screenDims[0],screenDims[1]);
  background(bg);
  
  lines = loadStrings("file.txt");
  
  getSongInfo();    //parse first line of file: should display start time, end time, song name, band name in that order. (separated by commas);

  
  song = new ArrayList<SongLine>(lines.length);
  for(int i = 1; i<lines.length; i++){        //Skip first line of file, which contains song info
    song.add(new SongLine(lines[i]));               
  } 
  clearAll();          //initialize screen
  
  loadTime = millis();
}
  
  
void draw() {
  timer();
  if(charSung){
    checkTimeline();
  }
  
  updateScreen();
}


void updateScreen(){
  
  //fill theBackground
  b.beginDraw();
  //b.noStroke();
  b.background(bg);
  b.endDraw();
  
  if(topLineTimes[0]<=timer&&topClear){
    writeTop();
  }
  if(topLineTimes[1]<=timer&&!topClear){
    clearTop();
  }
  if(botLineTimes[0]<=timer&&botClear){
    writeBot();
  }
  if(botLineTimes[1]<=timer&&!botClear){
    clearBot();
  }  
  
  //mask out theBackground w theText
  t.loadPixels();
  b.loadPixels();
  for(int i=0;i<t.pixels.length;i++) {
    //if white, change the color of the image to black with alpha = 0;
    if(t.pixels[i] > color(150)){
      color alphaCol = color(0,0);
      b.pixels[i] = alphaCol;
    }
  }
  
  b.updatePixels();
  
  if(singTime<=timer){
    //position = (charDistance/letterTime)*(timer-singTime)
    float x = singPos[0] + ((float(timer-singTime))/float(currentPhrase.letterTime))*(textWidth(currentChar));
    //println((timer-singTime)+" "+currentPhrase.letterTime+"  "+(textWidth(currentChar)));
    if(singTime+currentPhrase.letterTime>timer&&x<singPos[0]+textWidth(currentChar)){
      s.beginDraw();
      //s.noStroke();
      s.textFont(f);
      s.fill(sung);
      s.rect(0,singPos[1]-textAscent(),x+/*textWidth(currentChar)+*/textWidth(" "),singPos[1]+textDescent());
      //s.text(currentChar,singPos[0]+textWidth(" "),singPos[1]);
      s.endDraw();
    }else{
       println("sung    "+currentChar);
       charSung=true;       
       }
  }  
  
  image(s,0,0);    //draw theScan
  image(b,0,0);    //draw theBackground
  
  
} 
  

void checkTimeline(){
  charSung=false;
  if(lineNum < song.size()){  
    if(lineNum==0){
      setTopToSing(0);
      setBotToSing(1);
    }
    if(phraseNum==0){       
      currentLine=song.get(lineNum);
    }
    if(phraseNum<currentLine.songLine.size()){
      currentPhrase=currentLine.songLine.get(phraseNum);
      currentPhrase.getChar();
    }else{
      phraseNum=0;
      lineNum++;
      singTop=!singTop;
    }
  }else{
    println("DONE!!!");
    noLoop();
  }
}

void timer(){
      timer=millis()-loadTime;
}
  

void writeTop(){
  
  //fill theText
  t.beginDraw();
  t.textFont(f);
  //t.noStroke();
  t.fill(255);  //white will mask
  float x = topX;
  for (int i = 0; i < top.length(); i++) {
    t.text(top.charAt(i),x,topY);
    // textWidth() spaces the characters out properly.
    x += textWidth(top.charAt(i)); 
  }
  topClear=false;
  writeTop=false;
  t.endDraw();
} 
  

void writeBot(){  
  t.beginDraw();
  t.textFont(f);
  //t.noStroke();
  t.fill(255);  //white will mask
  float x = botX;
  for (int i = 0; i < bot.length(); i++) {
    t.text(bot.charAt(i),x,botY);
    x += textWidth(bot.charAt(i)); 
  }  
  botClear=false;
  writeTop=true;   
  t.endDraw();
} 
 
 
void clearTop(){
  t.beginDraw();
  //t.noStroke();
  t.fill(0);  //blk will not mask
  t.rect(0,0,screenDims[0],screenDims[1]/2);
  t.endDraw();
  
  s.beginDraw();
  //t.noStroke();
  s.fill(toSing);  
  s.rect(0,0,screenDims[0],screenDims[1]/2);
  s.endDraw();
  
  writeIndex+=2;
  topClear=true; 
  if(writeIndex<song.size()){
    setTopToSing(writeIndex);
    }
}


void clearBot(){
  t.beginDraw();
  //t.noStroke();
  t.fill(0);  //blk will not mask
  t.rect(0,screenDims[1]/2,screenDims[0],screenDims[1]);
  t.endDraw();
  
  s.beginDraw();
  //s.noStroke();
  s.fill(toSing);  
  s.rect(0,screenDims[1]/2,screenDims[0],screenDims[1]);
  s.endDraw();
  
  botClear=true;
  if(writeIndex+1<song.size()){
    setBotToSing(writeIndex+1);
    } 
}


void clearAll(){
  //fill theBackground
  b.beginDraw();
  //b.noStroke();
  b.background(bg);
  b.endDraw();
  
  //fill theText
  t.beginDraw();
  //t.noStroke();
  t.background(0);  //black will show up
  t.endDraw();
  
  s.beginDraw();
  //s.noStroke();
  s.background(toSing);
  s.endDraw();
  
  topClear=true;
  botClear=true;
}


void setTopToSing(int index){
  top=song.get(index).justTheWords;
  topX=song.get(index).lineOrigin;
  topLineTimes=song.get(index).lineTimes;
}

void setBotToSing(int index){
  bot=song.get(index).justTheWords;
  botLineTimes=song.get(index).lineTimes;
  botX=song.get(index).lineOrigin;
}

void getSongInfo(){
  String[] temp = split(lines[0],",");
  titleScreenTimes[0]=int(temp[0]);
  titleScreenTimes[1]=int(temp[1]);
  songName=temp[2];
  sungBy=temp[3];
}
  
void titleScreen(){} 
  

public class SongLine{
  int[] lineTimes;
  String theLine;
  ArrayList<SongPhrase> songLine;
  String justTheWords;
  float lineOrigin;
  
 SongLine(String theLine){  
   justTheWords="";
   songLine = new ArrayList<SongPhrase>();
   String splitLine[] =split(theLine,'\t');
   lineTimes=int(split(splitLine[0],','));
   for(int i=1; i<splitLine.length; i++){
     songLine.add(new SongPhrase(splitLine[i]));
   }
   for(SongPhrase phrase: songLine){
     phrase.phraseOrigin=textWidth(justTheWords);
     justTheWords=justTheWords+" "+phrase.phrase;
     
   }
   lineOrigin=(screenDims[0]-textWidth(justTheWords))/2;
 }
}





class SongPhrase{
  int startTime;
  int endTime;
  int drawTime;
  int letterTime;
  float phraseOrigin;  
  String phrase;

  SongPhrase(String thisPhrase){
    String[] splitPhrase=split(thisPhrase,',');
    startTime=int(splitPhrase[0]);
    endTime=int(splitPhrase[1]);
    phrase=splitPhrase[2];
    drawTime=endTime-startTime;
    letterTime=drawTime/phrase.length();
    phraseOrigin=0;
  }
  
  void getChar(){
    if(singTop){                                                      //get Y coordinate
      singPos[1]=topY;
    }else{
      singPos[1]=botY;
    }
    if(charNum<phrase.length()){                                      //get Char
      currentChar=phrase.charAt(charNum);        
      singTime=startTime+(letterTime*charNum);                        //get Sing Time
      if(charNum==0){                                                 //get X coordinate
      singPos[0]=phraseOrigin+currentLine.lineOrigin;       
      }else{
      singPos[0] += textWidth(phrase.charAt(charNum-1)); 
      }
      charNum++;
    }else{
       phraseNum++;
       charNum=0;   
    } 
  }
}
