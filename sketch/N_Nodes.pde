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
    copy.value = value;
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
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
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
    copy.value = value;
    return copy;
  }
  void update() {

    isFed = value >= needs - DELTAFLOAT;
    value -= needs;
    value = max(value, 0);

    super.update();
  }

  void preShow() {
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_Divider extends Node
{
  int outCount;
  N_Divider(float x, float y, int outCount ) {
    super(x, y);
    this.outCount = outCount;
    createPin(1, outCount);
  }

  N_Divider(float x, float y ) {
    super(x, y);
    this.outCount = 2;
    createPin(1, 2);
  }

  N_Divider copy()
  {
    N_Divider copy = new N_Divider(x+10, y+10, outCount);
    copy.value = value;
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
    createPin(inCount, 1);
  }

  N_Merger copy()
  {
    N_Merger copy = new N_Merger(x+10, y+10, inCount);
    copy.value = value;
    return copy;
  }

  void preShow()
  {
  }
}
