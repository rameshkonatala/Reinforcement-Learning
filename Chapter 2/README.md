# Chapter 2 - Multi-armed Bandits

## Exercise 2.1  
In ε-greedy action selection, for the case of two actions and ε = 0.5, what is the probability that the greedy action is selected?

Solution 2.1  
Probablity of selecting non greedy action = ε * selecting non greedy action among two actions = 0.5 * 0.5 = 0.25  
Probability of selecting the greedy action  = 1 - Probability of selecting non greedy action = 1 - 0.25 = 0.75  

## Exercise 2.2  
Bandit example Consider a k-armed bandit problem with k = 4 actions, denoted
1, 2, 3, and 4. Consider applying to this problem a bandit algorithm using ε-greedy action selection,
sample-average action-value estimates, and initial estimates of Q1(a) = 0, for all a. Suppose the initial
sequence of actions and rewards is A1 = 1, R1 = 1, A2 = 2, R2 = 1, A3 = 2, R3 = 2, A4 = 2, R4 = 2,
A5 = 3, R5 = 0. On some of these time steps the ε case may have occurred, causing an action to be
selected at random. On which time steps did this definitely occur? On which time steps could this
possibly have occurred?

Solution 2.2
There are 5 time steps which relates to taking 5 actions and 5 rewards. 
Thus k = 4. and a ∈ R<sup>k</sup>.
Time steps where action is definetely selected at random :  
* 2nd as it would have selected A<sub>1</sub> if it wasn't random given Q(a<sub>1</sub>) > Q(a<sub>2</sub>).
* 5th as it would have selected A<sub>2</sub> if it wasn't random given Q(a<sub>2</sub>) = 5/3> Q(a<sub>3</sub>) = 0

Time steps where action may be selected at random :  
* 1st as initially Q(a<sub>k</sub>) = 0 ∀ k.
* 3rd as Q(a<sub>1</sub>) = Q(a<sub>2</sub>) = 1 and it would have selected A<sub>2</sub> to break the tie.

## Exercise 2.3  
In the comparison shown in Figure 2.2, which method will perform best in the long run
in terms of cumulative reward and probability of selecting the best action? How much better will it
be? Express your answer quantitatively.  

Solution 2.3  
