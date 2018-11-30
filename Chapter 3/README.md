# Chapter 3 - Markov Decision Process

## Exercise 3.1  
Devise three example tasks of your own that fit into the MDP framework, identifying for
each its states, actions, and rewards. Make the three examples as different from each other as possible.
The framework is abstract and 
exible and can be applied in many different ways. Stretch its limits in
some way in at least one of your examples.

Solution 3.1   

| Scenario        | Actions           | States  |  Rewards  |
| ------------- |-------------| -----| ---- |  
| **Solving a rubics cube**      | Rotating the rows/columns of cube clockwise/anti-clockwise. | Arrangement of the cube. | +1 if same color tiles are present on same side of cube after one run if game. |
| **A manufacturing plant trying to reduce the waste generated.**    | Distrbution of parts to different departments within the organization.      |  Waste generation distribution across departments  | +1 if change in waste generation is negative. |
| **Optimize fuel intake of an automobile engine** | Opening and closing of fuel intake valve | Readings of fuel intake | +1 if rate of change of fuel intake if negative |
