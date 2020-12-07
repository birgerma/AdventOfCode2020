tree = dict()

class TreeNode:
    
    def __init__(self,name):
        self._name = name
        self._children = []
        self._parents = []

    def __str__(self):
        return self._name
    
    def addChild(self,child):
        self._children.append(child)
            
    def addParent(self, node):
        # if (self._parent!=None):
        #     raise Exception("Multiple parents!!!")
        self._parents.append(node)

    def getChildren(self):
        return self._children

    def recGetParents(self, prev=[]):
        print("Get parents for",self._name, len(self._parents), len(prev))
        for parent in self._parents:
            prev.append(parent)
            prev=parent.recGetParents(prev)
        return prev
        # if self._parent != None:
        #     prev.append(self._parent)
        #     return self._parent.recGetParents(prev)
        # else:
        #     return prev

    def recGetChildren(self):
        print("Get children:",self._name, len(self._children))
        children = []
        for child in self._children:
            children.append(child)
            children+=child.recGetChildren()
        return children
       
def readLines(fName):
    f = open(fName,'r')
    return f.read().split('\n')

def extractBags(lst):
    bags = []
    for i in range(0,len(lst),3):
        num = lst[i]
        if (num=='no'):
            # print("NO CHILDREN")
            return []
        color = "-".join(lst[i+1:i+3])
        # print("Extracting",num, color)
        bags.append((color, num))
    return bags

def asTreeNodes(bags):
    children = []
    for bag in bags:
        print(bag[0])
        if bag[0] not in tree.keys():
            tree[bag[0]] = TreeNode(bag[0])
        children.append(tree[bag[0]])
    return children
            
def formatRule(rawLine):
    lst = rawLine.split(" ")
    color = "-".join(lst[:2])
    lst = list(filter(lambda x:not x.startswith('bag'), lst))
    lst = lst[3:]
    bags = extractBags(lst)
    if color not in tree.keys():
        tree[color] = TreeNode(color)

    parents = asTreeNodes(bags)
    for parent in parents:
        parent.addChild(tree[color])

    
if __name__=='__main__':
    lines = readLines('example2')
    for line in lines:
        rule = formatRule(line)

    shinyGold = tree['shiny-gold']
    children = list(set(shinyGold.recGetChildren()))
    for child in children:
        print(child)
    print(len(children))

