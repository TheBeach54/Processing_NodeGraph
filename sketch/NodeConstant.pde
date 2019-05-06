color C_NODE_DEFAULT = color(150);
color C_NODE_FED = color(153, 180, 53);
color C_NODE_UNFED = color(211, 88, 53);
color C_NODE_STROKE = color(100);
color C_NODE_STROKE_SELECTED = color(250);
color C_BLOCKER_FILL = color(200, 39, 31);

color C_PIN_WATER = color(112, 143, 227);
color C_PIN_ELECTRIC = color(255, 236, 85);
color C_PIN_TEMPLATE = color(80,80,80,128);
color C_PIN_DEFAULT = color(150);
color C_PIN_CLICKED = color(250);
color C_PIN_STROKE = color(100);

color C_LINK_FULL = color(112, 143, 227);
color C_LINK_DEFAULT = color(200);
color C_LINK_INVALID = color(211, 88, 53);
color C_LINK_TEXT = color(250);

color C_WIDGET_DEFAULT = color(200);
color C_WIDGET_HELD = color(245);
color C_WIDGET_TEXT = color(5);
color C_WIDGET_STROKE = color(80);
color C_WIDGET_BACKGROUND = color(150);

color C_BACKGROUND = color(51);

float DELTAFLOAT = 0.001;

static abstract class NodeType
{
  static final int GENERATOR = 0;
  static final int POWERSUPPLY = 1;
  static final int RECEIVER = 2;
  static final int DIVIDER = 3;
  static final int MERGER = 4;
  static final int PASSER = 5;
  static final int SWITCH = 6;
  static final int POWERRECEIVER = 7;  
  static final int WATERMILL = 8;
}

static abstract class ValueType
{
  static final int UNDEFINED = -1;
  static final int WATER = 0;
  static final int ELECTRIC = 1;  
  static final int GAS = 1;
}
