import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch extends PApplet {

ArrayList<NodeTree> treeRoots; //<>// //<>// //<>//


NodeGraph nodeGraph; //<>//
float flowRate;
public void setup()
{
  
  nodeGraph = new NodeGraph(0);
  flowRate = 1;
}
public void mousePressed()
{
  nodeGraph.pressed();
}
public void mouseReleased()
{
  nodeGraph.released();
}

public void keyPressed()
{
  nodeGraph.keyPressed(key);
}

public void draw()
{
  background(C_BACKGROUND);
  nodeGraph.update();
  nodeGraph.show();
}
class Blocker extends Widget
{  
  Blocker(float x,float y,float xSize, float ySize)
  {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
  }
  
  public void show()
  {
    noStroke();
    fill(C_BLOCKER_FILL);
    rect(x,y,xSize,ySize);
  }
}

class N_Generator extends Node
{
  float generates = 1.0f;

  N_Generator(float x, float y) {
    super(x, y);
    this.generates = 1.0f;
    createPin(0, 1);
  }
  N_Generator(float x, float y, float generates) {
    super(x, y);
    this.generates = generates;
    createPin(0, 1);
  }
  public N_Generator copy()
  {
    N_Generator copy = new N_Generator(x+10, y+10);
    copy.value = value;
    return copy;
  }

  public void update() {
    isFed = value == oldValue;
    oldValue = value;
    value += generates;
    value = min(value, 255);

    super.update();
  }

  public void preShow() {
    super.preShow();
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_Receiver extends Node
{
  float needs = 1/3.0f;
  N_Receiver(float x, float y) {
    super(x, y);
    createPin(1, 0);
  }
  N_Receiver(float x, float y, float needs) {
    super(x, y);
    this.needs = needs;
    createPin(1, 0);
  }
  public N_Receiver copy()
  {
    N_Receiver copy = new N_Receiver(x+10, y+10);
    copy.value = value;
    return copy;
  }
  public void update() {

    isFed = value >= needs - DELTAFLOAT;
    value -= needs;
    value = max(value, 0);

    super.update();
  }

  public void preShow() {
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
    createPin(1, outCount);
  }

  N_Divider(float x, float y ) {
    super(x, y);
    this.outCount = 2;
    createPin(1, 2);
  }

  public N_Divider copy()
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

  public N_Merger copy()
  {
    N_Merger copy = new N_Merger(x+10, y+10, inCount);
    copy.value = value;
    return copy;
  }

  public void preShow()
  {
    super.preShow();
  }
}

class N_Passer extends Node
{
  N_Passer (float x, float y) {
    super(x, y);
    createPin(1, 1);
  }
  public N_Passer copy()
  {
    if (parent == null) {
      N_Passer copy = new N_Passer(x+10, y+10);
      copy.value = value;
      return copy;
    } else {
      return null;
    }
  }

  public void update() {

    if (inputs[0].connection > 0)
    {
      isFed = inputs[0].connectedLink.lastValue > DELTAFLOAT;
    } else
    {
      isFed = false;
    }
    value = min(value, 1.0f);
    super.update();
  }

  public void preShow()
  {
    super.preShow();
    value = min(value, 1.0f);
    fill(isFed?C_NODE_FED:C_NODE_UNFED);
  }
}

class N_Switch extends Node
{
  boolean state;


  N_Switch(float x, float y, Node child) {
    super(x, y);
    createPin(1, 2);

    this.child = child;
    child.assignParent(this);
  }

  public N_Switch copy() {
    nodeGraph.createPasser();
    N_Switch copy = new N_Switch(x+10, y+10, nodeGraph.getLastNode());
    copy.value = value;
    return copy;
  }

  public void destroy() {

    super.destroy();
  }


  public void update() {

    if (isDragged)
    {
      child.x = x;
      child.y = y - 40;
    } else
    {
      x = child.x;
      y = child.y+40;
    }
    if (isSelected)
      child.isSelected = true;

    if (child.isSelected)
      isSelected = true;

    state = child.isFed;
    outputs[0].isBlocked = state;
    outputs[1].isBlocked = !state;
    super.update();
  }

  public void preShow()
  {
    super.preShow();
    fill(state?C_NODE_FED:C_NODE_UNFED);
  }
}
class Widget
{
  float x, y;
  float xSize, ySize;

  boolean isDragged;

  Widget()
  {
    this.x = mouseX;
    this.y = mouseY;
    this.xSize = 50;
    this.ySize = 20;
    this.isDragged = false;
  }

  Widget(float x, float y)
  {
    this.x = x;
    this.y = y;
    this.xSize = 50;
    this.ySize = 20;
    this.isDragged = false;
  }

  public void show()
  {
    stroke(250);
    fill(C_NODE_DEFAULT);
    rect(x, y, xSize, ySize);
  }

  public boolean intersectLine(float startX, float startY, float endX, float endY) 
  { 
    PVector dir = new PVector(endX - startX, endY - startY);
    float len = dir.mag();
    dir.div(len);
    PVector min = new PVector(x, y);
    PVector max = new PVector(x+xSize, y+ySize);

    float tmin = (min.x - startX) / dir.x; 
    float tmax = (max.x - startX) / dir.x; 

    if (tmin > tmax) {    
      float temp = tmin;
      tmin = tmax;
      tmax = temp;
    }

    float tymin = (min.y - startY) / dir.y; 
    float tymax = (max.y - startY) / dir.y; 

    if (tymin > tymax) {
      float tempB = tymin;
      tymin = tymax;
      tymax = tempB;
    }

    if ((tmin > tymax) || (tymin > tmax)) 
      return false; 

    if (tymin > tmin) 
      tmin = tymin; 

    if (tymax < tmax) 
      tmax = tymax; 

    if (tmin>len)
      return false;

    if (tmax < 0 && tmin < 0)
      return false;

    return true;
  } 

  public boolean overlapRect(float rectX, float rectY, float rectSizeX, float rectSizeY)
  {
    float extentX = rectX + rectSizeX;
    float extentY = rectY + rectSizeY;
    float xmin = min(rectX, extentX);
    float xmax = max(rectX, extentX);
    float ymin = min(rectY, extentY);
    float ymax = max(rectY, extentY);

    return (!(y>ymax || y+ySize < ymin))&&(!(x > xmax || x+xSize < xmin));
  }

  public boolean mouseIsOverlapping()
  {
    return (mouseX > this.x && mouseX < (this.x + xSize) && mouseY > this.y && mouseY < this.y + this.ySize);
  }
}
class Node extends Widget
{
  // Node Helpers
  private float mOffX, mOffY;
  boolean isSelected;

  // Node Family
  Node parent;
  Node child;

  // Node Values
  float value;
  boolean isDestroyed = false;
  float oldValue;
  boolean isFed = false;

  // Node Pins
  NodePinOutput[] outputs;
  NodePinInput[] inputs;

  Node()
  {
    super();
    initialize();
  }
  Node(float x, float y)
  {
    super(x, y);
    initialize();
  }

  public void initialize()
  {
    this.mOffX = 0;
    this.mOffY = 0;
    this.value = 0;
  }

  public Node copy()
  {
    return null;
  }

  public void createPin(int inCount, int outCount) {
    this.outputs = new NodePinOutput[outCount];
    this.inputs = new NodePinInput[inCount];
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = new NodePinOutput(this, this.xSize-10, 20+ i * 20);
    }
    for (int i = 0; i < inputs.length; i++) {
      inputs[i] = new NodePinInput(this, 0, 20+ i * 20);
    }

    ySize = 20 + max(outputs.length, inputs.length) * 20;
  }


  public float getMaxAbsorb(float value)
  {
    float divideCount = 0;
    for ( NodePin pin : outputs) {
      if (pin.connection > 0 && pin.executed == 0)
        divideCount++;
    }
    return value/divideCount;
  }

  public float absorbValue(float v) {
    float maxAbsorb = getMaxAbsorb(value);
    float factored = min(v, maxAbsorb);

    value -= factored;
    return factored;
  }

  public void injectValue(float v) {
    value += v;
  }

  public boolean pressed()
  {
    if ( mouseIsOverlapping() )
    {
      mOffX = mouseX - x;
      mOffY = mouseY - y;
      for (NodePin pin : outputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.pressed();
          return false;
        }
      }
      for (NodePin pin : inputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.pressed();
          return false;
        }
      }
      isSelected = true;
      isDragged = true;
      return true;
    }
    return false;
  }

  public void released()
  {
    if ( mouseIsOverlapping() )
    {
      for (NodePin pin : outputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.drop();
          break;
        }
      }
      for (NodePin pin : inputs) {
        if (pin.mouseIsOverlapping())
        {
          pin.drop();
          break;
        }
      }
    } else
    {

      isSelected = false;
    }
    for (NodePin pin : outputs)
      pin.released();
    for (NodePin pin : inputs)
      pin.released();

    isDragged = false;
    // ---------
  }
  public void preUpdate()
  {    
    if (isDragged)
    {
      refreshLinks();
      if (child != null)
        child.refreshLinks();
      if (parent != null)
        parent.refreshLinks();

      x = mouseX - mOffX;
      y = mouseY - mOffY;
    }
  }
  public void refreshLinks() {
    for (NodePin pin : outputs) 
      pin.updateLink();

    for (NodePin pin : inputs)
      pin.updateLink();
  }
  public void update()
  {
    for (NodePin np : inputs)
      np.update();

    for (NodePin np : outputs)
      np.update();
  }

  public ArrayList<NodeLink> getLinks()
  {
    ArrayList<NodeLink> nls = new ArrayList<NodeLink>();
    for (NodePin np : inputs)
    {
      if (np!=null)
        nls.add(np.getLink());
    }
    for (NodePin np : outputs)
    {
      if (np!=null)
        nls.add(np.getLink());
    }
    return nls;
  }

  public void preShow()
  {
    for(NodePin np : outputs)
      np.preShow();
      
    for(NodePin np : inputs)
      np.preShow();
  }

  public void show()
  {
    strokeWeight(isSelected?2:1);
    stroke(C_NODE_STROKE);
    fill(C_NODE_DEFAULT);
    preShow();
    rectMode(CORNER);
    rect(x, y, xSize, ySize );
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].show();
    }
    for (int i = 0; i < inputs.length; i++) {
      inputs[i].show();
    }
    textAlign(CENTER);
    fill(C_LINK_TEXT);
    text(value, x + xSize/2, y + 20);
  }

  public void assignParent(Node n)
  {
    parent = n;
  }

  public void destroy() {    
    isDestroyed = true;
    if (child != null)
      if (!child.isDestroyed)
        nodeGraph.destroyNode(child); 
    if (parent != null)
      if (!parent.isDestroyed)
        nodeGraph.destroyNode(parent);
  }
}
int C_NODE_DEFAULT = color(150);
int C_NODE_FED = color(153, 180, 53);
int C_NODE_UNFED = color(211, 88, 53);
int C_NODE_STROKE = color(100);
int C_BLOCKER_FILL = color(200, 39, 31);

int C_PIN_WATER = color(112, 143, 227);
int C_PIN_DEFAULT = color(150);
int C_PIN_CLICKED = color(250);
int C_PIN_STROKE = color(100);

int C_LINK_FULL = color(112, 143, 227);
int C_LINK_DEFAULT = color(200);
int C_LINK_INVALID = color(211, 88, 53);
int C_LINK_TEXT = color(250);

int C_WIDGET_DEFAULT = color(200);
int C_WIDGET_HELD = color(245);
int C_WIDGET_TEXT = color(5);
int C_WIDGET_STROKE = color(80);
int C_WIDGET_BACKGROUND = color(150);

int C_BACKGROUND = color(51);

float DELTAFLOAT = 0.001f;

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

  float dragStartX = 0.0f;
  float dragStartY = 0.0f;

  NodePin pinTemp;

  NodeGraph(int nCount)
  {
    listNodes = new ArrayList<Node>();
    for (int i = 0; i< nCount; i++)
    {
      listNodes.add(new Node(random(width), random(height)));
    }

    listNodes.add(new N_Generator(50.0f, 50.0f));
    for (int i = 0; i < 8; i++) {
      listNodes.add(new N_Receiver(width - 100.0f, height - 50 - i*50));
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
  public void createGenerator()
  {
    listNodes.add(new N_Generator(mouseX, mouseY));
  }

  public void createReceiver()
  {
    listNodes.add(new N_Receiver(mouseX, mouseY));
  }

  public void createDivider()
  {
    listNodes.add(new N_Divider(mouseX, mouseY, floor(random(2, 5))));
  }

  public void createMerger()
  {
    listNodes.add(new N_Merger(mouseX, mouseY, floor(random(2, 5))));
  }

  public N_Passer createPasser()
  {
    N_Passer n = new N_Passer(mouseX, mouseY);
    listNodes.add(n);
    return n;
  }
  public Node getLastNode()
  {
    return listNodes.get(listNodes.size()-1);
  }
  public void createSwitch()
  {
    createPasser();
    listNodes.add(new N_Switch(mouseX, mouseY+40,getLastNode()));
  }

  public void createNode(int index)
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
  public void keyPressed(char key)
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

  public boolean validateLink(float ax, float ay, float bx, float by)
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
  public void update()
  {
    appendLinkQueue();


    for (Node n : listNodes)
      n.preUpdate();

    for (Node n : listNodes)
      n.update();

    for (NodeLink nl : listLinks)
      nl.execute();
  }

  public void show()
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

  public void pressed()
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
  public void released()
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

  public boolean connectionIsValid(NodePin a, NodePin b) {
    return ( a != null 
      && a != b 
      && a.isInput != b.isInput 
      && a.parent != b.parent
      && b.connection < 1
      && a.connection < 1);
  }

  public void addLinkStart(NodePin a) {
    isConnectingPin = false;
    pinTemp = a;
  }

  public void addLink(NodePin b)
  {
    isConnectingPin = true;
    if (connectionIsValid(pinTemp, b))
      addLink(pinTemp, b);
  }

  public void addLink(NodePin a, NodePin b)
  {
    linkQueue.add(new NodeLink(a, b));
  }

  public void appendLinkQueue()
  {
    for (NodeLink nl : linkQueue) {
      listLinks.add(nl);
    }
    if (linkQueue.size()>0)
      linkQueue = new ArrayList<NodeLink>();
  }

  public void deleteLink(NodeLink nl)
  {  
    if (!isConnectingPin)
    {
      nl.destroy();
      listLinks.remove(nl);
    }
  }


  public void deleteSelected()
  {
    ArrayList<Node> nodeToDestroy = new ArrayList<Node>();
    for (Node n : listNodes)
    {
      if (n.isSelected)
        nodeToDestroy.add(n);
    }
    destroyNodes(nodeToDestroy);
  }

  public void destroyNodes(ArrayList<Node> n)
  {
    for (int i = 0; i< n.size(); i++)
    {
      destroyNode(n.get(i));
    }
  }

  public void destroyNode(Node n)
  {
    if (n != null) {
      n.destroy();
      destroyLinks(n.getLinks());
      listNodes.remove(n);
    }
  }

  public void destroyLink(NodeLink nl)
  {
    if (listLinks.contains(nl))
    {
      nl.destroy();
      listLinks.remove(nl);
    }
  }


  public void destroyLinks(ArrayList<NodeLink> nls)
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

  public void copySelected()
  {
    ArrayList<Node> nodeToCopy = new ArrayList<Node>();
    for (Node n : listNodes)
    {
      if (n.isSelected)
        nodeToCopy.add(n);
    }
    copyNodes(nodeToCopy);
  }

  public void copyNodes(ArrayList<Node> n)
  {    
    for (int i = 0; i< n.size(); i++)
    {
      Node newNode = n.get(i).copy();
      if (newNode != null)
        listNodes.add(newNode);
    }
  }
}
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
  public void chainExecute()
  {
    chainExecute(this);
  }
  public void chainExecute(NodeLink start)
  {
    start.execute();
    for (NodePin np : start.out.parent.outputs) {
      if (np.connection > 0) {
        chainExecute(np.connectedLink);
      }
    }
  }

  public void update(){
    isValid = nodeGraph.validateLink(in.x, in.y, out.x, out.y);
  }


  public void execute() {
    
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

  public void destroy() {
    in.connectedLink = null;
    out.connectedLink = null;
    in.connection--;
    out.connection--;
  }



  public void show() {
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

class NodeTree {

  NodeTree parent;
  ArrayList<NodeTree> children;
  ArrayList<NodeLink> connections;

  Node node;

  NodeTree(Node node, NodeTree parent)
  {
    if (treeRoots == null)
      treeRoots = new ArrayList<NodeTree>();

    if (treeRoots.isEmpty())
      treeRoots.add(this);

    this.parent = parent;
    this.node = node;
    children = new ArrayList<NodeTree>();
    connections = new ArrayList<NodeLink>();
  }
 
  public void addChildren(Node newNode)
  {
    for (int i = 0; i < children.size(); i++)
    {
      if (children.get(i).node == node)
        return;
    }
    children.add(new NodeTree(newNode, this));
  }

  public NodeTree query(Node newNode)
  {
    if (newNode == node)
    {
      return this;
    }
    for (int i = 0; i < children.size(); i++)
    {
      if (children.get(i).node == newNode) {
        return children.get(i);
      }
    }
    
    NodeTree queryResult;
    for (int i = 0; i < children.size(); i++)
    {
      queryResult = children.get(i).query(newNode);
      if (queryResult != null)
        return queryResult;
    }
    return null;
  }

  public void addNode(Node newNode)
  {
  }
}
static abstract class NodeType
{
  static final int GENERATOR = 0;
  static final int RECEIVER = 1;
  static final int DIVIDER = 2;
  static final int MERGER = 3;
  static final int PASSER = 4;
  static final int SWITCH = 5;
}

static abstract class ValueType
{
  static final int WATER = 0;
  static final int ELECTRIC = 1;
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

  public void open(float x, float y)
  {
    this.x = x;
    this.y = y;
    isOpen = true;
    for (NodeMenuWidget w : menuWidgets)
    {
      w.update();
    }
  }
  public void pressed()
  {
    for (NodeMenuWidget w : menuWidgets)
    {
      if (w.mouseIsOverlapping())
      {
        w.isHeld = true;
      }
    }
  }

  public void released()
  {
    for (NodeMenuWidget w : menuWidgets)
    {
      w.isHeld = false;
    }
  }

  public void drop()
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

  public void close()
  {
    isOpen = false;
  }  

  public void show()
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

  public void clicked()
  {
    nodeGraph.createNode(index);
    parent.close();
  }

  public void update()
  {
    x = border + parent.x;
    y = border + parent.y + index * parent.widgetHeight;
    xSize = parent.xSize - border * 2;
    ySize = parent.widgetHeight - border * 2;
  }

  public void show()
  {
    strokeWeight(1);
    stroke(C_WIDGET_STROKE);
    fill(isHeld?C_WIDGET_HELD:C_WIDGET_DEFAULT);
    rect(x, y, xSize, ySize);
    fill(C_WIDGET_TEXT);
    text(name, x + xSize/2, y + ySize/2 + border * 2);
  }
}


class NodePin {

  float pinSize;
  boolean isHover;
  boolean isInput;

  boolean isBlocked = false;

  float locX, locY;
  float x, y;

  float xSize = 10;
  float ySize = 10;

  int connection;
  int executed;


  Node parent;
  NodeLink connectedLink;

  boolean isDragged = false;
  NodePin(Node parent, float locX, float locY) {
    this.locX = locX;
    this.locY = locY;
    this.parent = parent;
  }

  public boolean mouseIsOverlapping()
  {
    PVector pos = getPos();
    float posX = pos.x;
    float posY = pos.y;
    return (mouseX > posX && mouseX < (posX + xSize) && mouseY > posY && mouseY < posY + this.ySize);
  }

  public PVector getPos()
  {
    return new PVector(parent.x + locX, parent.y +locY);
  }
  public PVector getCenter()
  {
    return new PVector(parent.x + locX + xSize/2, parent.y+locY+ySize/2);
  }

  public void update() {
    executed = 0;
  }

  public void updatePos()
  {
    x = parent.x + locX;
    y = parent.y + locY;
  }

  public void updateLink() {
    if (connection > 0)
      connectedLink.update();
  }

  public void drop()
  {
    nodeGraph.addLink(this);
    isDragged = false;
  }

  public void pressed()
  {
    isDragged = true;
    nodeGraph.addLinkStart(this);
  }

  public NodeLink getLink()
  {
    return connectedLink;
  }

  public void released() 
  {
    if (isDragged) { 
      if (connection > 0) {
        nodeGraph.deleteLink(connectedLink);
      }
    }
    isDragged = false;
  }
  public void preShow()
  {
    updatePos();
  }
  public void show()
  {

    strokeWeight(1);
    stroke(C_PIN_STROKE);
    fill(executed>0?C_PIN_WATER:C_PIN_DEFAULT);
    if (isDragged)
      fill(C_PIN_CLICKED);


    rect(x, y, xSize, ySize);
    if (isDragged) {
      PVector cPos = getCenter();
      boolean valid = nodeGraph.validateLink(cPos.x, cPos.y, mouseX, mouseY);
      stroke(valid?C_LINK_DEFAULT:C_LINK_INVALID);
      strokeWeight(2);
      line(cPos.x, cPos.y, mouseX, mouseY);
    }
  }
}

class NodePinInput extends NodePin {
  NodePinInput(Node parent, float locX, float locY)
  {
    super(parent, locX, locY);
    this.isInput = true;
  }
}

class NodePinOutput extends NodePin {
  NodePinOutput(Node parent, float locX, float locY)
  {
    super(parent, locX, locY);
    this.isInput = false;
  }
}
  public void settings() {  size(600, 400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
