# Lab 6: Reinforcement Learning

[Pessiglione et al. (2006)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2636869/pdf/ukmss-3672.pdf) use a model of reinforcement learning to predict when people will experience a *reward prediction error* in a simple two-choice task. They use the model to find regions of the brain with activity patterns that correlate with the expected experienced reward prediction error.

## The experimental task

On each trial, subjects viewed two abstract visual stimuli and selected one of them. One of the shapes was associated with a high probability (0.8) of a positive reward (1£) and the other was associated with a low probability (0.2) of the positive reward. If the reward was not received, the subject got no money for that trial.

![Experimental Task Image](img/experiment-task.png)

Each subject in the experiment completed 30 trials. (*Note: there were also two other conditions, one with negative rewards and one with no rewards, but we don't need to model those for the purpose of this exercise*).

## The model

The reinforcement learning model describes the expected reward, ![equation 1](img/eq-1.gif), for selecting a particular stimulus. 

The model begins with the expected value of each stimulus (called A and B) at 0. 

The model chooses a stimulus using the *softmax* rule. This rule says that if you have a set of choices and each choice has some expected value, you choose probabilistically, assigning a higher probability to items with more value. This means that you don't always choose the option with the highest value. The *softmax* rule has a parameter called the *temperature*, denoted as ![equation 17](img/eq-17.gif). When this parameter is very **low** then the options the highest value are strongly preferred. When the parameter is **high** then there is more randomness in the decision making.  The equation that formalizes this approach is:

![equation 2](img/eq-2.gif)

This formula describes the probability of selecting stimulus A at time ![equation 3](img/eq-3.gif), ![equation 4](img/eq-4.gif), based on the current expected value of choosing A, ![equation 5](img/eq-5.gif), and choosing B, ![equation 6](img/eq-6.gif). In R, ![equation 7](img/eq-7.gif) raised to a power can be achieved with the `exp()` function.

Once the model makes a choice, it receives a reward ![equation 8](img/eq-8.gif). In our example this reward can be either 0 or 1.

The model then updates the expected value of the choice. Say the model chose A at time step ![equation 3](img/eq-3.gif). The new expected value of A at time step ![equation 9](img/eq-9.gif) would become:

![equation 10](img/eq-10.gif)

where

![equation 11](img/eq-11.gif)

Let's break down the formulas here. 

The first formula says that the new expected value of A, ![equation 12](img/eq-12.gif), is equal to the old expected value of A, ![equation 5](img/eq-5.gif), plus ![equation 13](img/eq-13.gif). So the first thing to notice is that this model is changing the expected value based on new information, not assigning a new expected value after every trial.

![equation 14](img/eq-14.gif) describes the *difference* between the actual reward and the model's expected reward. This is shown in the second equation. The actual reward at time ![equation 3](img/eq-3.gif) is ![equation 15](img/eq-15.gif) and the model's expected reward at time ![equation 3](img/eq-3.gif) is ![equation 5](img/eq-5.gif). 

The final puzzle piece is ![equation 16](img/eq-16.gif), which is the learning rate parameter. If ![equation 16](img/eq-16.gif) is very large, then the model will update its expectations very quickly. If ![equation 16](img/eq-16.gif) is small, then the model will only update the expected reward a little bit after each trial.

Note that the expected value of the stimulus that was not selected is not updated.

## Your task

1. Start with `mini-tutorial.R`. This will teach you one new trick that is useful for completing the lab.
2. Implement the reinforcement learning model in `model.R`, and answer a few questions.



