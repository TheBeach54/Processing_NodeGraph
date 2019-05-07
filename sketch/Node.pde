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

    return true;
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

  boolean mouseIsOverlapping()
  {
    return (mouseX > this.x && mouseX < (this.x + xSize) && mouseY > this.y && mouseY < this.y + this.ySize);
  }
}

class Node extends Widget
{
  // Node Helpers
  private float mOffX, mOffY;
  boolean isSelected;

  // Node Family
  Node parent;
  Node child;

  // Node Values
  float value;
  boolean isDestroyed = false;
  float oldValue;
  boolean isFed = false;
  int valueType = ValueType.WATER;

  // Node Pins
  ArrayList<NodePinOutput> outputs;
  ArrayList<NodePinInput> inputs;

  boolean outputExtensible = false;
  boolean inputExtensible = false;

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
    this.outputs = new ArrayList<NodePinOutput>();
    this.inputs = new ArrayList<NodePinInput>();
    for (int i = 0; i < outCount; i++) {
      outputs.add(new NodePinOutput(this, this.xSize-10, 20+ i * 20));
    }
    for (int i = 0; i < inCount; i++) {
      inputs.add( new NodePinInput(this, 0, 20+ i * 20));
    }

    addNewInputTemplate();
    addNewOutputTemplate();
    refreshSize();
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

  void injectValue(float v) {
    value += v;
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
      refreshLinks();
      if (child != null)
        child.refreshLinks();
      if (parent != null)
        parent.refreshLinks();

      x = mouseX - mOffX;
      y = mouseY - mOffY;
    }
  }
  void refreshLinks() {
    for (NodePin pin : outputs) 
      pin.updateLink();

    for (NodePin pin : inputs)
      pin.updateLink();
  }
  void updatePinType()
  {
    for (NodePin pin : outputs)
      pin.updateType();
    for (NodePin pin : inputs)
      pin.updateType();
  }
  void assignType(int type)
  {
    valueType = type;
    updatePinType();
  }
  void update()
  {


    if (child != null)
    {    
      if (isDragged)
      {
        child.x = x;
        child.y = y - 40;
      } else
      {
        x = child.x;
        y = child.y+40;
      }
      if (isSelected)
        child.isSelected = true;

      if (child.isSelected)
        isSelected = true;
    }

    for (NodePin np : inputs)
    {
      np.update();
    }

    for (NodePin np : outputs)
    {   
      np.update();
    }
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
    for (NodePin np : outputs)
      np.preShow();

    for (NodePin np : inputs)
      np.preShow();
  }

  void show()
  {
    strokeWeight(isSelected?2:1);
    stroke(isSelected?C_NODE_STROKE_SELECTED:C_NODE_STROKE);
    fill(C_NODE_DEFAULT);
    preShow();
    rectMode(CORNER);
    rect(x, y, xSize, ySize );
    for (int i = 0; i < outputs.size(); i++) {
      outputs.get(i).show();
    }
    for (int i = 0; i < inputs.size(); i++) {
      inputs.get(i).show();
    }
    textAlign(CENTER);
    fill(C_LINK_TEXT);
    text(value, x + xSize/2, y + 20);
  }

  void assignParent(Node n)
  {
    parent = n;
  }
  void addNewInputTemplate()
  {
    if (inputExtensible)
    {
      inputs.add(new NodePinInputTemplate(this, 0, 20+inputs.size() * 20));
      refreshSize();
    }
  }
  void addNewOutputTemplate()
  {
    if (outputExtensible) {
      outputs.add(new NodePinOutputTemplate(this, this.xSize-10, 20+outputs.size() * 20));
      refreshSize();
    }
  }

  void refreshSize()
  {
    ySize = 20 + max(outputs.size(), inputs.size()) * 20;
  }

  NodePin replaceTemplate(NodePin template)
  {
    if (template.isTemplate)
    {
      for (int i = inputs.size()-1; i>= 0; i--)
      {
        if (inputs.get(i) == template)
        {         
          NodePinInput np = new NodePinInput(template.parent, template.locX, template.locY);
          inputs.add(i, np);
          inputs.remove(i+1);
          addNewInputTemplate();
          return inputs.get(i);
        }
      }
      for (int i = outputs.size()-1; i>= 0; i--)
      {
        if (outputs.get(i) == template)
        {         

          NodePinOutput np = new NodePinOutput(template.parent, template.locX, template.locY);
          outputs.add(i, np);
          outputs.remove(i+1);
          addNewOutputTemplate();
          return outputs.get(i);
        }
      }
      return null;
    }
    return template;
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
}
