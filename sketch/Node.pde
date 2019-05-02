class Widget
{
  float x, y;
  float xSize, ySize;

  boolean isDragged;

  Widget()
  {
    this.x = mouseX;
    this.y = mouseY;
    this.xSize = 50;
    this.ySize = 20;
    this.isDragged = false;
  }

  Widget(float x, float y)
  {
    this.x = x;
    this.y = y;
    this.xSize = 50;
    this.ySize = 20;
    this.isDragged = false;
  }

  void show()
  {
    stroke(250);
    fill(C_NODE_DEFAULT);
    rect(x, y, xSize, ySize);
  }

  boolean intersectLine(float startX, float startY, float endX, float endY) 
  { 
    PVector dir = new PVector(endX - startX, endY - startY);
    float len = dir.mag();
    dir.div(len);
    PVector min = new PVector(x, y);
    PVector max = new PVector(x+xSize, y+ySize);

    float tmin = (min.x - startX) / dir.x; 
    float tmax = (max.x - startX) / dir.x; 

    if (tmin > tmax) {    
      float temp = tmin;
      tmin = tmax;
      tmax = temp;
    }


    float tymin = (min.y - startY) / dir.y; 
    float tymax = (max.y - startY) / dir.y; 

    if (tymin > tymax) {
      float tempB = tymin;
      tymin = tymax;
      tymax = tempB;
    }

    if ((tmin > tymax) || (tymin > tmax)) 
      return false; 

    if (tymin > tmin) 
      tmin = tymin; 

    if (tymax < tmax) 
      tmax = tymax; 

    if (tmin>len)
      return false;

    if (tmax < 0 && tmin < 0)
      return false;

    //float tzmin = (min.z - r.orig.z) / r.dir.z; 
    //float tzmax = (max.z - r.orig.z) / r.dir.z; 

    //if (tzmin > tzmax) swap(tzmin, tzmax); 

    //if ((tmin > tzmax) || (tzmin > tmax)) 
    //  return false; 

    //if (tzmin > tmin) 
    //  tmin = tzmin; 

    //if (tzmax < tmax) 
    //  tmax = tzmax; 

    return true;
  } 

  //boolean intersectLine(float ax, float ay, float bx, float by)
  //{
  //  PVector start = new PVector(ax, ay);
  //  PVector end = new PVector(bx, by);
  //  PVector ray = end.sub(start);
  //  PVector perp = new PVector(end.y - start.y, start.x - end.x);

  //  PVector[] point = {new PVector(x, y), new PVector(x+xSize, y), new PVector(x+xSize, y+ySize), new PVector(x, y+ySize)};
  //  PVector toPoint = new PVector(point[0].x - start.x, point[0].y - start.y);
  //  float test = PVector.dot(perp, toPoint);
  //  for (int i = 1; i<4; i++)
  //  {
  //    toPoint = new PVector(point[i].x - start.x, point[i].y - start.y);
  //    if ((test<=0)!= (PVector.dot(perp, toPoint)<=0))
  //      return true;
  //  }

  //  return false;
  //}

  boolean overlapRect(float rectX, float rectY, float rectSizeX, float rectSizeY)
  {
    float extentX = rectX + rectSizeX;
    float extentY = rectY + rectSizeY;
    float xmin = min(rectX, extentX);
    float xmax = max(rectX, extentX);
    float ymin = min(rectY, extentY);
    float ymax = max(rectY, extentY);

    return (!(y>ymax || y+ySize < ymin))&&(!(x > xmax || x+xSize < xmin));
  }

  boolean mouseIsOverlapping()
  {
    return (mouseX > this.x && mouseX < (this.x + xSize) && mouseY > this.y && mouseY < this.y + this.ySize);
  }
}
class Node extends Widget
{
  // Node Helpers
  float mOffX, mOffY;

  boolean isSelected;

  float oldValue;
  boolean isFed = false;

  Node parent;
  Node child;

  boolean isDestroyed = false;
  // Node Values
  float value;

  // Node Pins
  NodePinOutput[] outputs;
  NodePinInput[] inputs;

  Node()
  {
    super();
    initialize();
  }
  Node(float x, float y)
  {
    super(x, y);
    initialize();
  }

  void initialize()
  {

    this.mOffX = 0;
    this.mOffY = 0;


    this.value = 0;
  }

  Node copy()
  {
    return null;
  }

  void createPin(int inCount, int outCount) {
    this.outputs = new NodePinOutput[outCount];
    this.inputs = new NodePinInput[inCount];
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = new NodePinOutput(this, this.xSize-10, 20+ i * 20);
    }
    for (int i = 0; i < inputs.length; i++) {
      inputs[i] = new NodePinInput(this, 0, 20+ i * 20);
    }

    ySize = 20 + max(outputs.length, inputs.length) * 20;
  }


  float getMaxAbsorb(float value)
  {
    float divideCount = 0;
    for ( NodePin pin : outputs) {
      if (pin.connection > 0 && pin.executed == 0)
        divideCount++;
    }
    return value/divideCount;
  }

  float absorbValue(float v) {
    float maxAbsorb = getMaxAbsorb(value);
    float factored = min(v, maxAbsorb);

    value -= factored;
    return factored;
  }


  boolean pressed()
  {
    if ( mouseIsOverlapping() )
    {
      mOffX = mouseX - x;
      mOffY = mouseY - y;
      for (NodePin pin : outputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.pressed();
          return false;
        }
      }
      for (NodePin pin : inputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.pressed();
          return false;
        }
      }
      isSelected = true;
      isDragged = true;
      return true;
    }
    return false;
  }

  void released()
  {


    if ( mouseIsOverlapping() )
    {
      for (NodePin pin : outputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.drop();
          break;
        }
      }
      for (NodePin pin : inputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.drop();
          break;
        }
      }
    } else
    {

      isSelected = false;
    }
    for (NodePin pin : outputs)
      pin.released();
    for (NodePin pin : inputs)
      pin.released();

    isDragged = false;
    // ---------
  }
  void preUpdate()
  {    
    if (isDragged)
    {
      for (NodePin pin : outputs) 
        pin.updateLink();

      for (NodePin pin : inputs)
        pin.updateLink();
        
      x = mouseX - mOffX;
      y = mouseY - mOffY;
    }
  }
  void update()
  {

    for (NodePin np : inputs)
      np.update();

    for (NodePin np : outputs)
      np.update();
  }



  ArrayList<NodeLink> getLinks()
  {
    ArrayList<NodeLink> nls = new ArrayList<NodeLink>();
    for (NodePin np : inputs)
    {
      if (np!=null)
        nls.add(np.getLink());
    }
    for (NodePin np : outputs)
    {
      if (np!=null)
        nls.add(np.getLink());
    }
    return nls;
  }

  void preShow()
  {
  }

  void show()
  {
    strokeWeight(isSelected?4:1);
    stroke(200);
    fill(C_NODE_DEFAULT);
    preShow();
    rectMode(CORNER);
    rect(x, y, xSize, ySize );
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].show();
    }
    for (int i = 0; i < inputs.length; i++) {
      inputs[i].show();
    }
    textAlign(CENTER);
    fill(255);
    text(value, x + xSize/2, y + 20);
  }

  void assignParent(Node n)
  {
    parent = n;
  }

  void destroy() {    
    isDestroyed = true;
    if (child != null)
      if (!child.isDestroyed)
        nodeGraph.destroyNode(child); 
    if (parent != null)
      if (!parent.isDestroyed)
        nodeGraph.destroyNode(parent);
  }

  void injectValue(float v) {
    value += v;
  }
}
