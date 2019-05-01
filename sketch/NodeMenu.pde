class NodeMenu 
{
  float x, y;
  float xSize, ySize;
  String[] strings = {"N_Generator", "N_Receiver", "N_Divider", "N_Merger"};
  ArrayList<NodeMenuWidget> menuWidgets;
  float widgetHeight = 20;

  boolean open = false;
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
    open = true;
  }

  void close()
  {
    open = false;
  }  

  void show()
  {
    if (open) {
      strokeWeight(1);
      fill(C_NODE_DEFAULT);
      rect(x, y, xSize, ySize);

      for (NodeMenuWidget w : menuWidgets)
      {
        w.show();
      }
    }
  }

  boolean mouseIsOverlapping()
  {
    return (mouseX > this.x && mouseX < (this.x + xSize) && mouseY > this.y && mouseY < this.y + this.ySize);
  }
}

class NodeMenuWidget
{
  NodeMenu parent;
  String name;
  int index;
  float border = 2;

  NodeMenuWidget(NodeMenu parent, String name, int index)
  {
    this.parent = parent;
    this.name = name;
    this.index = index;
  }

  void clicked()
  {
    nodeGraph.createNode(name);
  }
  
  void update()
  {
    
  }

  void show()
  {
     
    rect(border + parent.x, 
      border + parent.y+index*parent.widgetHeight, 
      parent.xSize - border * 2, 
      parent.widgetHeight - border * 2);
  }
}
