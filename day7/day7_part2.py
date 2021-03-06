tree = dict()

class TreeNode:
    
    def __init__(self,name):
        self._name = name
        self._children = []
        self._parents = []
        self._numbers = []

    def __str__(self):
        return self._name
    
    def addChild(self,child, num=1):
        self._children.append(child)
        self._numbers.append(int(num))
            
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
        print("Get children:",self._name, len(self._children), len(self._numbers))
        children = []
        for i in range(len(self._children)):
            children.append((self._children[i], self._numbers[i]))
            children+=self._children[i].recGetChildren()
        return children

    def recGetNumberOfChildren(self):
        # print("Get Number of children:",self._name, len(self._children), len(self._numbers))
        # if len(self._children)==0:
        #     print(self._name,"contains no bags")
        #     return 1
        nChildren = 0
        for i in range(len(self._children)):
            print(self._name, "contains",self._numbers[i],self._children[i]._name)
            # print(self._numbers[i], self._children[i].recGetNumberOfChildren())
            # print(self._numbers[i]*self._children[i].recGetNumberOfChildren())
            # print(type(nChildren), type(self._numbers[i]))
            nChildren += (self._numbers[i]*self._children[i].recGetNumberOfChildren())
            print("Nchildren:", nChildren)
        return nChildren+1

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

    children = asTreeNodes(bags)
    numbers = []
    print(bags)
    for bag in bags:
        numbers.append(bag[1])
    print("Numbers:",numbers)
    for i in range(len(children)):
        tree[color].addChild(children[i], numbers[i])

    
if __name__=='__main__':
    lines = readLines('input')
    for line in lines:
        rule = formatRule(line)

    shinyGold = tree['shiny-gold']
    # children = list(set(shinyGold.recGetChildren()))
    nChildren = shinyGold.recGetNumberOfChildren()
    print("Total children:", nChildren-1)
    # for child in children:
    #     print(child)
    # print(len(children))

