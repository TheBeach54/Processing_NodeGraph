class Blocker extends Widget
{  
  Blocker(float x,float y,float xSize, float ySize)
  {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
  }
  
  void show()
  {
    noStroke();
    fill(C_BLOCKER_FILL);
    rect(x,y,xSize,ySize);
  }
}
