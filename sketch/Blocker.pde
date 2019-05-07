class TypeFilter
{
  boolean[] blockTypes;
  TypeFilter()
  {
    blockTypes = new boolean[ValueType.COUNT];

    for (int i = 0; i < blockTypes.length; i ++) {
      blockTypes[i] = true;
    }
  }
  
  TypeFilter(boolean def, int typeA)
  {
    blockTypes = new boolean[ValueType.COUNT];
    for (int i = 0; i < blockTypes.length; i ++) {
      blockTypes[i] = def;
    }
    blockTypes[typeA] = !def;
  }

  boolean isBlocking(int type)
  {
    return blockTypes[type];
  }
}

class Blocker extends Widget
{  
  TypeFilter filter;
  Blocker(float x, float y, float xSize, float ySize)
  {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
    this.filter = new TypeFilter();
  }

  Blocker(float x, float y, float xSize, float ySize, TypeFilter filter)
  {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
    this.filter = filter;
    if (filter == null)
    {
      this.filter = new TypeFilter();
    }
  }

  boolean isBlockingType(int type)
  {
    if (filter.isBlocking(type))
      return true;
    return false;
  }


  void show()
  {
    color col = C_BLOCKER_FILL + C_BLOCKER_FILL;
    noStroke();
    fill(col);
    rect(x, y, xSize, ySize);
  }
}
