
class NodeGraph
{
  ArrayList<Node> listNodes;
  ArrayList<NodeLink> listLinks;
  ArrayList<NodeLink> linkQueue;

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

  //-----------------
  // Common Function
  void update()
  {
    appendLinkQueue();

    for (Node n : listNodes)
      n.update();

    for (NodeLink nl : listLinks)
      nl.execute();
  }

  void show()
  {
    for (Node n : listNodes)
      n.show();

    for (NodeLink nl : listLinks)
      nl.show();

    if (isDragged) {
      fill(100, 100, 100, 100);
      rect(mouseX, mouseY, dragStartX-mouseX, dragStartY-mouseY);
    }
  }

  void pressed()
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
    if (!found)
    {
      isDragged = true;
      dragStartX = mouseX;
      dragStartY = mouseY;
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
    isDragged = false;
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
      destroyLinks(n.get(i).getLinks());
      listNodes.remove(n.get(i));
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
