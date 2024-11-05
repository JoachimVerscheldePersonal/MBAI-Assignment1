## Step 0:
- holds(at(t1,d1),0)
- occurs(move(t1,d1,v10),0)
- move_distance(t1,0,65)
## Step 1:
- holds(at(t1,v10),1)
- occurs(move(t1,v10,v9),1)
- move_distance(t1,1,60)
## Step 2:
- holds(at(t1,v9),2)
- occurs(move(t1,v9,c1),2)
- move_distance(t1,2,60)
## Step 3:
- holds(at(t1,c1),3)
- occurs(move(t1,c1,v6),3)
- holds(delivered(c1),3)
- move_distance(t1,3,39)
## Step 4:
- holds(at(t1,v6),4)
- occurs(move(t1,v6,v5),4)
- holds(delivered(c1),4)
- move_distance(t1,4,75)
## Step 5:
- holds(at(t1,v5),5)
- occurs(move(t1,v5,c2),5)
- holds(delivered(c1),5)
- move_distance(t1,5,80)
## Step 6:
- holds(at(t1,c2),6)
- holds(delivered(c1),6)
- holds(delivered(c2),6)
## Step 7:
- holds(at(t1,c2),7)
- holds(delivered(c1),7)
- holds(delivered(c2),7)
## Step 8:
- holds(at(t1,c2),8)
- holds(delivered(c1),8)
- holds(delivered(c2),8)
## Step 9:
- holds(delivered(c1),9)
- holds(delivered(c2),9)
## Step 10:
- holds(delivered(c1),10)
- holds(delivered(c2),10)
## Step 11:
- holds(delivered(c2),11)
- holds(delivered(c1),11)
                               