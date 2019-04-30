
class NodePin {

  float pinSize;
  boolean isHover;
  boolean isInput;

  float locX, locY;

  float xSize = 10;
  float ySize = 10;

  int connection;
  int executed;

  Node parent;
  NodeLink connectedLink;

  boolean isDragged = false;
  NodePin(Node parent, float locX, float locY) {
    this.locX = locX;
    this.locY = locY;
    this.parent = parent;
  }

  boolean mouseIsOverlapping()
  {
    PVector pos = getPos();
    float posX = pos.x;
    float posY = pos.y;
    return (mouseX > posX && mouseX < (posX + xSize) && mouseY > posY && mouseY < posY + this.ySize);
  }

  PVector getPos()
  {
    return new PVector(parent.x + locX, parent.y +locY);
  }
  PVector getCenter()
  {
    return new PVector(parent.x + locX + xSize/2, parent.y+locY+ySize/2);
  }

  void update() {
    executed = 0;
  }

  void drop()
  {
    nodeGraph.addLink(this);
    isDragged = false;
  }

  void pressed()
  {
    isDragged = true;
    nodeGraph.addLinkStart(this);
  }

  NodeLink getLink()
  {
    return connectedLink;
  }

  void released() 
  {
    if (isDragged) { 
      if (connection > 0) {
        nodeGraph.deleteLink(connectedLink);
      }
    }
    isDragged = false;
  }
  void show()
  {
    strokeWeight(1);
    stroke(C_PIN_STROKE);
    fill(executed>0?C_PIN_WATER:C_PIN_DEFAULT);
    if (isDragged)
      fill(C_PIN_CLICKED);
    rect(parent.x + locX, parent.y + locY, xSize, ySize);
    if (isDragged) {
      PVector cPos = getCenter();
      stroke(C_LINK_DEFAULT);
      strokeWeight(2);
      line(cPos.x, cPos.y, mouseX, mouseY);
    }
  }
}

class NodePinInput extends NodePin {
  NodePinInput(Node parent, float locX, float locY)
  {
    super(parent, locX, locY);
    this.isInput = true;
  }
}

class NodePinOutput extends NodePin {
  NodePinOutput(Node parent, float locX, float locY)
  {
    super(parent, locX, locY);
    this.isInput = false;
  }
}
