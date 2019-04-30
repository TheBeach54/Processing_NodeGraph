
class Node
{
  // Node Helpers
  float x, y;
  float xSize, ySize;

  float mOffX, mOffY;

  boolean isDragged;
  boolean isSelected;

  float oldValue;
  boolean isFed = false;

  // Node Values
  float value;

  // Node Pins
  NodePinOutput[] outputs;
  NodePinInput[] inputs;

  Node()
  {
    initialize(mouseX, mouseY);
  }
  Node(float x, float y)
  {
    initialize(x, y);
  }

  void initialize(float x, float y)
  {
    this.x = x;
    this.y = y;
    this.xSize = 50;
    this.ySize = 20;
    this.mOffX = 0;
    this.mOffY = 0;
    this.isDragged = false;

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
  void update()
  {
    if (isDragged)
    {
      x = mouseX - mOffX;
      y = mouseY - mOffY;
    }
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
  void injectValue(float v) {
    value += v;
  }


  boolean mouseIsOverlapping()
  {
    return (mouseX > this.x && mouseX < (this.x + xSize) && mouseY > this.y && mouseY < this.y + this.ySize);
  }
}
