static abstract class NodeType
{
  static final int GENERATOR = 0;
  static final int RECEIVER = 1;
  static final int DIVIDER = 2;
  static final int MERGER = 3;
  static final int PASSER = 4;
  static final int SWITCH = 5;
}

class NodeMenu extends Widget
{
  String[] strings = 
    {
    "Generator", 
    "Receiver", 
    "Divider", 
    "Merger", 
    "Passer", 
    "Switch"
  };
  ArrayList<NodeMenuWidget> menuWidgets;
  float widgetHeight = 20;

  boolean isOpen = false;
  NodeMenu()
  {
    x = 0;
    y = 0;
    xSize = 80;
    ySize = strings.length * widgetHeight;
    menuWidgets = new ArrayList<NodeMenuWidget>();
    for (int i = 0; i< strings.length; i++)
    {
      menuWidgets.add(new NodeMenuWidget(this, strings[i], i));
    }
  }

  void open(float x, float y)
  {
    this.x = x;
    this.y = y;
    isOpen = true;
    for (NodeMenuWidget w : menuWidgets)
    {
      w.update();
    }
  }
  void pressed()
  {
    for (NodeMenuWidget w : menuWidgets)
    {
      if (w.mouseIsOverlapping())
      {
        w.isHeld = true;
      }
    }
  }

  void released()
  {
    for (NodeMenuWidget w : menuWidgets)
    {
      w.isHeld = false;
    }
  }

  void drop()
  {
    for (NodeMenuWidget w : menuWidgets)
    {
      if (w.mouseIsOverlapping() && w.isHeld == true && isOpen)
      {
        w.clicked();
      }
      w.isHeld = false;
    }
  }

  void close()
  {
    isOpen = false;
  }  

  void show()
  {
    if (isOpen) {
      strokeWeight(1);
      fill(C_NODE_DEFAULT);
      rect(x, y, xSize, ySize);

      for (NodeMenuWidget w : menuWidgets)
      {
        w.show();
      }
    }
  }
}

class NodeMenuWidget extends Widget
{
  NodeMenu parent;
  String name;
  int index;
  float border = 2;
  boolean isHeld;

  NodeMenuWidget(NodeMenu parent, String name, int index)
  {
    this.parent = parent;
    this.name = name;
    this.index = index;
  }

  void clicked()
  {
    nodeGraph.createNode(index);
    parent.close();
  }

  void update()
  {
    x = border + parent.x;
    y = border + parent.y + index * parent.widgetHeight;
    xSize = parent.xSize - border * 2;
    ySize = parent.widgetHeight - border * 2;
  }

  void show()
  {
    strokeWeight(1);
    stroke(250);
    fill(isHeld?C_WIDGET_DEFAULT:C_WIDGET_HELD);
    rect(x, y, xSize, ySize);
    fill(C_LINK_TEXT);
    text(name, x + xSize/2, y + ySize/2 + border * 2);
  }
}
