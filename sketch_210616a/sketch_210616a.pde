import KinectPV2.*;
KinectPV2 kinect;


Agent[]as;

PVector center;

PImage img;

void setup() {
  fullScreen();  
  background(0);

  stroke(255, 5);

  as=new Agent[500];
  for (int i=0; i<as.length; i++) {
    as[i]=new Agent();
  }

  center=new PVector(0, 0);

  kinect = new KinectPV2(this);
  //Start up methods go here
  kinect.enableDepthImg(true);
  kinect.init();
  img = createImage(KinectPV2.WIDTHDepth, KinectPV2.HEIGHTDepth, RGB);
  print(KinectPV2.WIDTHDepth);//512
  print(KinectPV2.HEIGHTDepth);//424
}

void draw() {

  img.loadPixels();

  int [] depth = kinect.getRawDepthData();

  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;

  for (int x = 0; x < KinectPV2.WIDTHDepth; x++) {
    for (int y = 0; y < KinectPV2.HEIGHTDepth; y++) {
      // Mirroring the image
      int offset = x + y * KinectPV2.WIDTHDepth;
      // Grabbing the raw depth
      int d = depth[offset];

      if (d > 0 && d < 800) {
        img.pixels[offset]=color(255, 0, 150);
        sumX += x;
        sumY += y;
        totalPixels++;
      } else {
        img.pixels[offset]=color(0);
      }
    }
  }

  img.updatePixels();
  //  image(img, 0, 0);

  float avgX = 0;
  float avgY = 0;
  if (totalPixels!=0) {
    avgX = sumX /totalPixels;
    avgY = sumY /totalPixels;
    fill(150, 0, 255);
  } else {
    avgX = 256;
    avgY = 212;
  }

  //  print(avgX);
  //  print(avgY);
  float controlX = map(avgX, 0, 512, 0, width);
  float controlY = map(avgY, 0, 424, 0, height);
  //  print(controlX);
  //  print(controlY);
  //  ellipse(controlX, controlY, 64, 64);

  PVector mp= new PVector(controlX, controlY);
  PVector spd=PVector.sub(mp, center);
  spd.mult(0.1);
  center.add(spd);

  if (mousePressed) {
    background(0);
  }

  for (int i=0; i<as.length; i++) {
    as[i].update(center);
  }
}



class Agent {

  PVector pos;
  PVector prevPos;
  PVector spd; 
  float individualFactor;

  Agent() {
    pos=new PVector(random(width), random(height));
    prevPos=pos.copy();

    spd=new PVector(0, 0);    
    individualFactor=random(0.2, 5);
  }

  void update(PVector target) {
    PVector acc=PVector.sub(target, pos);
    acc.mult(0.01);
    acc.mult(individualFactor);

    spd.add(acc);
    pos.add(spd);

    spd.mult(0.96);

    line(pos.x, pos.y, prevPos.x, prevPos.y);

    prevPos=pos.copy();
  }
}
