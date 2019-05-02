class NodeLink {
  NodePin in;
  NodePin out;

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
    
    update();
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

  void update(){
    isValid = nodeGraph.validateLink(in.x, in.y, out.x, out.y);
  }


  void execute() {
    
    if (!(in.isBlocked || out.isBlocked) && isValid) {
      lastValue = in.parent.absorbValue(flowRate);
      out.parent.injectValue(lastValue);
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
    if(!isValid)
      stroke(C_LINK_INVALID);
      
    strokeWeight(2);
    line(start.x, start.y, end.x, end.y);
    textAlign(CENTER);
    fill(C_LINK_TEXT);
    text(lastValue, (start.x + end.x)/2, (start.y+end.y)/2 - 5);
  }
}
