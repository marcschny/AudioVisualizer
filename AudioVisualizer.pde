import processing.sound.*;

// Change the number of samples to extract and draw a longer/shorter part of the waveform.
// Define how many samples of the Waveform you want to be able to read at once
int noOfSamples = 1024;

// Declare the sound source and Waveform analyzer variables
SoundFile sample;
Waveform waveform;

FFT fft;
int bands = 256;
float[] spectrum = new float[bands];

//fixed beat detection value
float detectionValue = 0.22;


public void settings()
{
  size(512, 512);
}

public void setup()
{
  background(255);

  // Load and play a soundfile and loop it.
  sample = new SoundFile(this, "myTrack.wav");
  sample.loop();

  // Create the Waveform analyzer and connect the playing soundfile to it.
  // See class definition:
  // https://github.com/processing/processing-sound/blob/master/src/processing/sound/Waveform.java
  waveform = new Waveform(this, noOfSamples);
  waveform.input(sample);
  
  // Create an Input stream which is routed into the Amplitude analyzer
  // and execute an FFT to create the frequency spectrum
  // See: https://processing.org/reference/libraries/sound/FFT.html
  fft = new FFT(this, bands);
  fft.input(sample);
  
  //re-draw
  frameRate(60);
}

public void draw()
{
  // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();

  // Perform the analysis
  // Generate array with amplitudes in waveform.data[] - size of array: noOfSamples 
  waveform.analyze();

  float nMax = noOfSamples-1;
  
  for(int i = 0; i < noOfSamples-1; i++)
  {
    line(
      i/nMax*width,
      waveform.data[i]*height/2 + height/2,

      (i+1)/nMax*width,
      waveform.data[i+1]*height/2 + height/2
    );
  }

  // Detect beat
  boolean beatDetected = false;
  // count how many times it was detected
  int detectionCount = 0;
  
  for (int i = 0; i < noOfSamples / 4; i++){
    float posValue;
    //set positive values
    if (waveform.data[i] < 0 ) posValue = -waveform.data[i];
    else posValue = waveform.data[i];
    
    //increase detectionCount
    // if the positive value is bigger than my fixed detection value
    if( posValue > detectionValue ){
        detectionCount++;
    }
  }
  
  //to avoid flickering
  //(i had to try a bit to find a suitable value)
  if (detectionCount > 86){
     beatDetected = true;
  }
  
  if (beatDetected)
  {
    textSize(48);
    text("BEAT", 100,100);
  }
  
  // Create spectrum
  // The array spectrum[bands] contains now normalized values, describing the frequency spectrum
  // I.e., spectrum[bands]
  fft.analyze(spectrum);
  for(int i = 0; i < bands-1; i++)
  {
    // Helpfull commands:
    // stroke(red, green, blue); // set color of line
    // line( x0,y0, x1,y1 );
    
    //increase red and decrease green value for each band
    stroke(0+i, 255-i, 0);
    
    
    //top right
    line(
      width/2+i, height/2,
      width/2+i, height/2 - spectrum[i]*height/2
    );
    
    
    //bottom right
    line(
      width/2+i, height/2,
      width/2+i, height/2 + spectrum[i]*height/2
    );
    
    
    //bottom left
    line(
      width/2-i, height/2,
      width/2-i, height/2 - spectrum[i]*height/2
    );
    
    
    //top left
    line(
      width/2-i, height/2,
      width/2-i, height/2 + spectrum[i]*height/2
    );

  }
  
  stroke(1,1,1);
  
}
