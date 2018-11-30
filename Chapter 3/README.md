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

## Exercise 3.2
Is the MDP framework adequate to usefully represent all goal-directed learning tasks?
Can you think of any clear exceptions?  

Solution 3.2  

No because of following reasons.  
- It makes assumption that the current state depends on just previous state and action which might not be always true.  
- It requires environment to give a reward signal at all time steps which might not happen always.


## Exercise 3.3
Consider the problem of driving. You could dene the actions in terms of the accelerator,
steering wheel, and brake, that is, where your body meets the machine. Or you could define them farther
out|say, where the rubber meets the road, considering your actions to be tire torques. Or you could
define them farther in|say, where your brain meets your body, the actions being muscle twitches to
control your limbs. Or you could go to a really high level and say that your actions are your choices of
where to drive. What is the right level, the right place to draw the line between agent and environment?
On what basis is one location of the line to be preferred over another? Is there any fundamental reason
for preferring one location over another, or is it a free choice?  

Solution 3.3  
It would be optimal to draw line can be where you expect the reward from environment is delayed least as it can limit the possible action-space needed to explore.   

