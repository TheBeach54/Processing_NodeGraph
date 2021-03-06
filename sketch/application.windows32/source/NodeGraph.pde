
class NodeGraph
{
  ArrayList<Node> listNodes;
  ArrayList<NodeLink> listLinks;
  ArrayList<NodeLink> linkQueue;
  ArrayList<Blocker> blockers;
  NodeMenu nodeMenu;

  int maxConnection = 1;

  boolean isDragged = false;
  boolean isConnectingPin = false;

  float dragStartX = 0.0;
  float dragStartY = 0.0;

  NodePin pinTemp;

  NodeGraph(int nCount)
  {
    listNodes = new ArrayList<Node>();
    for (int i = 0; i< nCount; i++)
    {
      listNodes.add(new Node(random(width), random(height)));
    }

    listNodes.add(new N_Generator(50.0, 50.0));
    for (int i = 0; i < 8; i++) {
      listNodes.add(new N_Receiver(width - 100.0, height - 50 - i*50));
    }

    blockers = new ArrayList<Blocker>();

    blockers.add(new Blocker(width/2, 0, 40, height/2-20));
    blockers.add(new Blocker(width/2, height/2+20, 40, height/2-20));

    nodeMenu = new NodeMenu();
    linkQueue = new ArrayList<NodeLink>();
    listLinks = new ArrayList<NodeLink>();
    pinTemp = null;
  }


  //---------------
  // Node Creation
  void createGenerator()
  {
    listNodes.add(new N_Generator(mouseX, mouseY));
  }

  void createReceiver()
  {
    listNodes.add(new N_Receiver(mouseX, mouseY));
  }

  void createDivider()
  {
    listNodes.add(new N_Divider(mouseX, mouseY, floor(random(2, 5))));
  }

  void createMerger()
  {
    listNodes.add(new N_Merger(mouseX, mouseY, floor(random(2, 5))));
  }

  N_Passer createPasser()
  {
    N_Passer n = new N_Passer(mouseX, mouseY);
    listNodes.add(n);
    return n;
  }
  Node getLastNode()
  {
    return listNodes.get(listNodes.size()-1);
  }
  void createSwitch()
  {
    createPasser();
    listNodes.add(new N_Switch(mouseX, mouseY+40,getLastNode()));
  }

  void createNode(int index)
  {
    switch(index)
    {
    case NodeType.GENERATOR:
      createGenerator();
      break;
    case NodeType.RECEIVER: 
      createReceiver();
      break;
    case NodeType.DIVIDER: 
      createDivider();
      break;
    case NodeType.MERGER: 
      createMerger();
      break;
    case NodeType.PASSER: 
      createPasser();
      break;
    case NodeType.SWITCH: 
      createSwitch();
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
      createGenerator();
      break;
    case 'r' :
      createReceiver();
      break;
    case 'd' :
      createDivider();
      break;
    case 'm' : 
      createMerger();
      break;
    default :
      break;
    }
  }

  boolean validateLink(float ax, float ay, float bx, float by)
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
    appendLinkQueue();


    for (Node n : listNodes)
      n.preUpdate();

    for (Node n : listNodes)
      n.update();

    for (NodeLink nl : listLinks)
      nl.execute();
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
      if (nodeMenu.mouseIsOverlapping())
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
      && b.connection < 1
      && a.connection < 1);
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
    linkQueue.add(new NodeLink(a, b));
  }

  void appendLinkQueue()
  {
    for (NodeLink nl : linkQueue) {
      listLinks.add(nl);
    }
    if (linkQueue.size()>0)
      linkQueue = new ArrayList<NodeLink>();
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
    if (n != null) {
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
