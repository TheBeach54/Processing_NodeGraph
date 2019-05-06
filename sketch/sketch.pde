ArrayList<NodeTree> treeRoots;  //<>// //<>//
NodeGraph nodeGraph;
float flowRate;

void setup()
{
  size(600, 400);
  flowRate = 1;
  nodeGraph = new NodeGraph(0);
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
  background(C_BACKGROUND);
  nodeGraph.update();
  nodeGraph.show();
}
