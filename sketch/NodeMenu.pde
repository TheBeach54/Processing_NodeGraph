

class NodeMenu extends Widget
{
  String[] strings = 
    {
    "Generator", 
    "Power Supply", 
    "Receiver", 
    "Divider", 
    "Merger", 
    "Passer", 
    "Switch", 
    "Power Receiver", 
    "Water Mill"
  };
  ArrayList<NodeMenuWidget> menuWidgets;
  float widgetHeight = 20;

  boolean isOpen = false;
  NodeMenu()
  {
    x = 0;
    y = 0;
    xSize = 10;
    for (String s : strings)
    {
      xSize = max(xSize, s.length()*8);
    }
    ySize = strings.length * widgetHeight;
    menuWidgets = new ArrayList<NodeMenuWidget>();
    for (int i = 0; i< strings.length; i++)
    {
      menuWidgets.add(new NodeMenuWidget(this, strings[i], i));
    }
  }

  void open(float x, float y)
  {
    this.x = min(x, width-xSize);
    this.y = min(y, height-ySize);

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
      stroke(C_WIDGET_STROKE);
      strokeWeight(1);
      fill(C_WIDGET_BACKGROUND);
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
    nodeGraph.createNode(parent.x + parent.xSize/3, parent.y + parent.ySize/3, index);
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
    stroke(C_WIDGET_STROKE);
    fill(isHeld?C_WIDGET_HELD:C_WIDGET_DEFAULT);
    rect(x, y, xSize, ySize);
    fill(C_WIDGET_TEXT);
    text(name, x + xSize/2, y + ySize/2 + border * 2);
  }
}
