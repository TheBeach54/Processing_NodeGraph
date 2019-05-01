
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
 
  void addChildren(Node newNode)
  {
    for (int i = 0; i < children.size(); i++)
    {
      if (children.get(i).node == node)
        return;
    }
    children.add(new NodeTree(newNode, this));
  }

  NodeTree query(Node newNode)
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

  void addNode(Node newNode)
  {
  }
}
