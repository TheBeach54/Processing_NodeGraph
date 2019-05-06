class N_Generator extends Node
{
  float generates = 1.0;

  N_Generator(float x, float y) {
    super(x, y);
    this.generates = 1.0;
    createPin(0, 1);
  }
  N_Generator(float x, float y, float generates) {
    super(x, y);
    this.generates = generates;
    createPin(0, 1);
  }
  N_Generator copy()
  {
    N_Generator copy = new N_Generator(x+10, y+10);
    return copy;
  }

  void update() {
    isFed = value == oldValue;
    oldValue = value;
    value += generates;
    value = min(value, 255);

    super.update();
  }

  void preShow() {
    super.preShow();
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}
class N_PowerSupply extends N_Generator
{
  N_PowerSupply(float x, float y)
  {
    super(x, y);
    valueType = ValueType.ELECTRIC;
    updatePinType();
  }
  N_PowerSupply(float x, float y, float generates)
  {
    super(x, y, generates);
    valueType = ValueType.ELECTRIC;
    updatePinType();
  }
}
class N_PowerReceiver extends N_Receiver
{
  N_PowerReceiver(float x, float y)
  {
    super(x, y);
    valueType = ValueType.ELECTRIC;
    updatePinType();
  }
  N_PowerReceiver(float x, float y, float needs)
  {
    super(x, y, needs);
    valueType = ValueType.ELECTRIC;
    updatePinType();
  }
  N_PowerReceiver copy()
  {
    N_PowerReceiver copy = new N_PowerReceiver(x+10, y+10);
    return copy;
  }
}

class N_Receiver extends Node
{
  float needs = 1/3.0;
  N_Receiver(float x, float y) {
    super(x, y);
    createPin(1, 0);
  }
  N_Receiver(float x, float y, float needs) {
    super(x, y);
    this.needs = needs;
    createPin(1, 0);
  }
  N_Receiver copy()
  {
    N_Receiver copy = new N_Receiver(x+10, y+10);
    return copy;
  }
  void update() {

    isFed = value >= needs - DELTAFLOAT;
    value -= needs;
    value = max(value, 0);

    super.update();
  }

  void preShow() {
    super.preShow();
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_Divider extends Node
{
  int outCount;
  N_Divider(float x, float y, int outCount ) {
    super(x, y);
    this.outCount = outCount;
    valueType = -1;
    outputExtensible = true;
    createPin(1, outCount);
  }

  N_Divider(float x, float y ) {
    super(x, y);
    this.outCount = 1;
    valueType = -1;
    outputExtensible = true;
    createPin(1, 1);
  }

  N_Divider copy()
  {
    N_Divider copy = new N_Divider(x+10, y+10, outCount);
    return copy;
  }
}

class N_Merger extends Node
{
  int inCount;
  N_Merger(float x, float y, int inCount)
  {
    super(x, y);
    this.inCount = inCount;
    valueType = -1;
    inputExtensible = true;
    createPin(inCount, 1);
  }
  N_Merger(float x, float y)
  {
    super(x, y);
    this.inCount = 1;
    valueType = -1;
    inputExtensible = true;
    createPin(inCount, 1);
  }

  N_Merger copy()
  {
    N_Merger copy = new N_Merger(x+10, y+10, inCount);
    return copy;
  }
}

class N_Passer extends Node
{
  N_Passer (float x, float y) {
    super(x, y);
    valueType = -1;
    createPin(1, 1);
  }
  N_Passer copy()
  {
    if (parent == null) 
    { 
      N_Passer copy = new N_Passer(x+10, y+10); 
      return copy;
    } else 
    { 
      return null;
    }
  }

  void update() {

    if (inputs.get(0).connection > 0)
    {
      isFed = inputs.get(0).connectedLink.lastValue > DELTAFLOAT;
    } else
    {
      isFed = false;
    }
    value = min(value, 1.0);
    super.update();
  }

  void preShow()
  {
    super.preShow();
    value = min(value, 1.0);
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_Switch extends Node
{
  boolean state;


  N_Switch(float x, float y, Node child) {
    super(x, y);
    valueType = -1;
    createPin(1, 2);

    this.child = child;
    child.assignParent(this);
  }

  N_Switch copy() {
    nodeGraph.createPasser();
    N_Switch copy = new N_Switch(x+10, y+10, nodeGraph.getLastNode());
    return copy;
  }

  void destroy() {
    super.destroy();
  }

  void update() {
    state = child.isFed;
    outputs.get(0).isBlocked = state;
    outputs.get(1).isBlocked = !state;
    super.update();
  }

  void preShow()
  {
    super.preShow();
    fill(state?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_WaterMill extends Node
{
  boolean state;


  N_WaterMill(float x, float y, Node child) {
    super(x, y);
    valueType = ValueType.ELECTRIC;
    createPin(0, 1);

    this.child = child;
    child.assignParent(this);

    child.assignType(ValueType.WATER);
  }

  N_WaterMill copy() {
    nodeGraph.createPasser();
    N_WaterMill copy = new N_WaterMill(x+10, y+10, nodeGraph.getLastNode());
    return copy;
  }

  void destroy() {
    super.destroy();
  }

  void update() {
    state = child.isFed;
    value = min(value, 1.0);
    if (state)
      value += flowRate;



    super.update();
  }

  void preShow()
  {
    super.preShow();
    fill(state?C_NODE_FED:C_NODE_UNFED);
  }
}
