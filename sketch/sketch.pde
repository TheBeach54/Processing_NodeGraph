ArrayList<NodeTree> treeRoots; //<>// //<>// //<>// //<>//


NodeGraph nodeGraph; //<>// //<>//
float flowRate;
void setup()
{
  size(600, 400);
  nodeGraph = new NodeGraph(0);
  flowRate = 1;
}
void mousePressed()
{
  nodeGraph.pressed();
}
void mouseReleased()
{
  nodeGraph.released();
}

void keyPressed()
{
  nodeGraph.keyPressed(key);
}

void draw()
{
  background(51);
  nodeGraph.update();
  nodeGraph.show();
}
