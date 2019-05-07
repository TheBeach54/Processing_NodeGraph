ArrayList<NodeTree> treeRoots;  //<>// //<>//
NodeGraph nodeGraph;
float flowRate;

void setup()
{
  size(800, 600);
  flowRate = 1;
  nodeGraph = new NodeGraph();
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
