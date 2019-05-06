class NodeLink {
  NodePin in;
  NodePin out;

  int valueType;

  float lastValue;
  boolean isValid;

  NodeLink(NodePin in, NodePin out)
  {
    this.in = out.isInput ? in : out;
    this.out = out.isInput ? out : in;

    in.connectedLink = this;
    out.connectedLink = this;
    in.connection++;
    out.connection++;

    conformType();

    this.valueType = out.parent.valueType;
    updateCollisions();
  }
  void chainExecute()
  {
    chainExecute(this);
  }
  void chainExecute(NodeLink start)
  {
    start.execute();
    for (NodePin np : start.out.parent.outputs) {
      if (np.connection > 0) {
        chainExecute(np.connectedLink);
      }
    }
  }

  void assignType(int type)
  {
    valueType = type;
  }

  boolean conformType()
  {
    boolean test = false;
    if (in.valueType == -1)
    {
      in.parent.assignType(out.valueType);
      if(in.parent.valueType != -1)
        test = true;
    }
    if (out.valueType == -1)
    {
      out.parent.assignType(in.valueType);
      if(out.parent.valueType != -1)
        test = true;
    }
    return test;
  }

  void update() {


    lastValue = 0;
  }

  void updateCollisions() {
    PVector inC = in.getCenter();
    PVector outC = out.getCenter();
    isValid = nodeGraph.validateLine(inC.x, inC.y, outC.x, outC.y);
  }

  void execute() {

    if (!(in.isBlocked || out.isBlocked) && isValid) {
      float temp = in.parent.absorbValue(flowRate);
      lastValue += temp;
      out.parent.injectValue(temp);
    } else
    {
      lastValue = 0;
    }
    in.executed++;
    out.executed++;
  }

  void destroy() {
    in.connectedLink = null;
    out.connectedLink = null;
    in.connection--;
    out.connection--;
  }



  void show() {
    PVector start = in.getCenter();
    PVector end = out.getCenter();
    stroke(lastValue>0?C_LINK_FULL:C_LINK_DEFAULT);
    if (!isValid)
      stroke(C_LINK_INVALID);

    strokeWeight(2);
    line(start.x, start.y, end.x, end.y);
    textAlign(CENTER);
    fill(C_LINK_TEXT);
    text(lastValue, (start.x + end.x)/2, (start.y+end.y)/2 - 5);
  }
}
