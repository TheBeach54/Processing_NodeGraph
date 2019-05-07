
class NodeGraph
{
  ArrayList<Node> listNodes;
  ArrayList<NodeLink> listLinks;
  ArrayList<NodeLink> linkQueue;
  ArrayList<Blocker> blockers;

  TypeFilter filterBlockWater;
  TypeFilter filterBlockElectric;

  NodeMenu nodeMenu;

  int maxConnection = 1;

  boolean isDragged = false;
  boolean isConnectingPin = false;
  boolean isPressing = false;

  float dragStartX = 0.0;
  float dragStartY = 0.0;

  NodePin pinTemp;

  NodeGraph()
  {
    listNodes = new ArrayList<Node>();

    listNodes.add(new N_Generator(50.0, 50.0));
    for (int i = 0; i < 8; i++) {
      N_Receiver nr = new N_Receiver(width - 100.0, height - 50 - i*50);
      nr.isStatic = true;
      nr.isPermanent = true;
      listNodes.add(nr);
    }

    filterBlockWater = new TypeFilter(false, ValueType.WATER);
    filterBlockElectric = new TypeFilter(false, ValueType.ELECTRIC);

    blockers = new ArrayList<Blocker>();

    blockers.add(new Blocker(width/2, 0, 50, height/3, filterBlockElectric));
    blockers.add(new Blocker(width/2, height/3, 50, height/3));
    blockers.add(new Blocker(width/2, 2*height/3, 50, height/3, filterBlockWater));


    nodeMenu = new NodeMenu();
    linkQueue = new ArrayList<NodeLink>();
    listLinks = new ArrayList<NodeLink>();
    pinTemp = null;
  }


  //---------------
  // Node Creation
  void createGenerator(float x, float y)
  {
    listNodes.add(new N_Generator(x, y));
  }
  void createPower(float x, float y)
  {
    listNodes.add(new N_PowerSupply(x, y));
  }
  void createReceiver(float x, float y)
  {
    listNodes.add(new N_Receiver(x, y));
  }
  void createDivider(float x, float y)
  {
    listNodes.add(new N_Divider(x, y));
  }
  void createPowerReceiver(float x, float y)
  {    
    listNodes.add(new N_PowerReceiver(x, y));
  }
  void createMerger(float x, float y)
  {
    listNodes.add(new N_Merger(x, y));
  }
  void createWaterMill(float x, float y)
  {
    createPasser(x, y);
    listNodes.add(new N_WaterMill(x, y, getLastNode()));
  }

  N_Passer createPasser(float x, float y)
  {
    N_Passer n = new N_Passer(x, y);
    listNodes.add(n);
    return n;
  }

  void createSwitch(float x, float y)
  {
    createPasser(x, y);
    listNodes.add(new N_Switch(x, y+40, getLastNode()));
  }
  Node getLastNode()
  {
    return listNodes.get(listNodes.size()-1);
  }

  void createNode(float x, float y, int index)
  {
    switch(index)
    {
    case NodeType.GENERATOR:
      createGenerator(x, y);
      break;
    case NodeType.POWERSUPPLY:
      createPower(x, y);
      break;
    case NodeType.RECEIVER: 
      createReceiver(x, y);
      break;
    case NodeType.DIVIDER: 
      createDivider(x, y);
      break;
    case NodeType.MERGER: 
      createMerger(x, y);
      break;
    case NodeType.PASSER: 
      createPasser(x, y);
      break;
    case NodeType.SWITCH: 
      createSwitch(x, y);
      break;
    case NodeType.POWERRECEIVER:
      createPowerReceiver(x, y);
      break;
    case NodeType.WATERMILL:
      createWaterMill(x, y);
      break;
    }
  }
  void keyPressed(char key)
  {

    switch(key) {
    case DELETE :
      deleteSelected();
      break;
    case 'c' :
      copySelected();
      break;
    case 'g' :
      createGenerator(mouseX, mouseY);
      break;
    case 'r' :
      createReceiver(mouseX, mouseY);
      break;
    case 'd' :
      createDivider(mouseX, mouseY);
      break;
    case 'm' : 
      createMerger(mouseX, mouseY);
      break;
    default :
      break;
    }
  }

  boolean validateLine(float ax, float ay, float bx, float by, int type)
  {
    for (Blocker b : blockers)
    {
      if (b.intersectLine(ax, ay, bx, by) && b.isBlockingType(type))
      {
        return false;
      }
    }
    return true;
  }

  boolean validateLine(float ax, float ay, float bx, float by)
  {
    for (Blocker b : blockers)
    {
      if (b.intersectLine(ax, ay, bx, by))
      {
        return false;
      }
    }
    return true;
  }
  //-----------------
  // Common Function
  void update()
  {
    if (mousePressed && !isPressing) {
      pressed();      
      isPressing = true;
    }
    if (!mousePressed && isPressing) {
      released();
      isPressing = false;
    }

    if (appendLinkQueue())
      conformAllLinks();

    for (Node n : listNodes)
      n.preUpdate();

    for (Node n : listNodes)
      n.update();

    for (NodeLink nl : listLinks)
      nl.update();

    executeLinks();
  }

  void executeLinks()
  {
    //Backward loop over every node and execute the outputs
    for (int i = listNodes.size()-1; i>=0; i--) {
      for (NodePin np : listNodes.get(i).outputs) {
        np.executeLinks();
      }
    }
    //Simple Backward loop over links
    //for (int i = listLinks.size()-1; i>=0; i--)
    //  listLinks.get(i).execute();    

    // Simple loop over links
    //for (NodeLink nl : listLinks)
    //  nl.execute();

    // Execture all links from the generators, 
    // Links will be executed n*N_Gen_affecting_it
    //for (Node n : listNodes) {
    //  if (n instanceof N_Generator) {
    //    if (n.outputs.get(0).connectedLink != null)
    //      n.outputs.get(0).connectedLink.chainExecute();
    //  }
    //}
  }


  void show()
  {
    for (Blocker b : blockers)
      b.show();

    for (Node n : listNodes)
      n.show();

    for (NodeLink nl : listLinks)
      nl.show();



    if (isDragged) {
      fill(100, 100, 100, 100);
      rect(mouseX, mouseY, dragStartX-mouseX, dragStartY-mouseY);
    }
    nodeMenu.show();
  }

  void pressed()
  {
    if (mouseButton == LEFT)
    {

      boolean found = false;
      for (int i = listNodes.size()-1; i>=0; i--)
      {
        found = listNodes.get(i).mouseIsOverlapping();
        if (found)
        {
          listNodes.get(i).pressed();
          Node temp = listNodes.get(i);
          listNodes.remove(i);
          listNodes.add(temp);        
          break;
        }
      }
      if (nodeMenu.mouseIsOverlapping() && nodeMenu.isOpen)
      {
        found = true;
        nodeMenu.pressed();
      } else
      {
        nodeMenu.close();
      }


      if (!found)
      {

        isDragged = true;
        dragStartX = mouseX;
        dragStartY = mouseY;
      }
    } else if (mouseButton == RIGHT)
    {
      nodeMenu.open(mouseX, mouseY);
    }
  }
  void released()
  {

    for (Node n : listNodes)
      n.released();

    if (isDragged)
    {
      for (Node n : listNodes)
      {
        n.isSelected = n.overlapRect(mouseX, mouseY, dragStartX-mouseX, dragStartY-mouseY);
      }
    } 

    if (nodeMenu.mouseIsOverlapping())
    {
      nodeMenu.drop();
    } else
    {
      nodeMenu.released();
    }

    isDragged = false;
  }

  //---------------------------------------
  //Node NodePin NodeLink wrapper functions

  boolean connectionIsValid(NodePin a, NodePin b) {
    return ( a != null 
      && a != b 
      && a.isInput != b.isInput 
      && a.parent != b.parent
      && b.connection == 0
      && a.connection == 0
      &&(( a.valueType == b.valueType)
      ||(a.valueType == -1)
      ||(b.valueType == -1)));
  }

  void addLinkStart(NodePin a) {
    isConnectingPin = false;
    pinTemp = a;
  }

  void addLink(NodePin b)
  {
    isConnectingPin = true;
    if (connectionIsValid(pinTemp, b))
      addLink(pinTemp, b);
  }


  void addLink(NodePin a, NodePin b)
  {       
    linkQueue.add(new NodeLink(a.parent.replaceTemplate(a), b.parent.replaceTemplate(b)));
  }

  void conformAllLinks()
  {
    for (NodeLink nl : listLinks) {
      if (nl.conformType())
      {        
        conformAllLinks();
        break;
      }
    }
  }

  boolean appendLinkQueue()
  {
    for (NodeLink nl : linkQueue) {
      listLinks.add(nl);
    }
    if (linkQueue.size()>0)
    {
      linkQueue = new ArrayList<NodeLink>();
      return true;
    }
    return false;
  }

  void deleteLink(NodeLink nl)
  {  
    if (!isConnectingPin)
    {
      nl.destroy();
      listLinks.remove(nl);
    }
  }


  void deleteSelected()
  {
    ArrayList<Node> nodeToDestroy = new ArrayList<Node>();
    for (Node n : listNodes)
    {
      if (n.isSelected)
        nodeToDestroy.add(n);
    }
    destroyNodes(nodeToDestroy);
  }

  void destroyNodes(ArrayList<Node> n)
  {
    for (int i = 0; i< n.size(); i++)
    {
      destroyNode(n.get(i));
    }
  }

  void destroyNode(Node n)
  {
    if (n != null && !n.isPermanent) {
      n.destroy();
      destroyLinks(n.getLinks());
      listNodes.remove(n);
    }
  }

  void destroyLink(NodeLink nl)
  {
    if (listLinks.contains(nl))
    {
      nl.destroy();
      listLinks.remove(nl);
    }
  }


  void destroyLinks(ArrayList<NodeLink> nls)
  {
    for (int j = 0; j< nls.size(); j++)
    {
      if (listLinks.contains(nls.get(j)))
      {
        nls.get(j).destroy();
        listLinks.remove(nls.get(j));
      }
    }
  }

  void copySelected()
  {
    ArrayList<Node> nodeToCopy = new ArrayList<Node>();
    for (Node n : listNodes)
    {
      if (n.isSelected)
        nodeToCopy.add(n);
    }
    copyNodes(nodeToCopy);
  }

  void copyNodes(ArrayList<Node> n)
  {    
    for (int i = 0; i< n.size(); i++)
    {
      Node newNode = n.get(i).copy();
      if (newNode != null)
        listNodes.add(newNode);
    }
  }
}
