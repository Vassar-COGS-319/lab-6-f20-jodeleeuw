library(dplyr)
library(ggplot2)

# this model will simulate a group of subjects completing the experiment described in the README.
# your job is to implement the reinforcement learning model

# experiment parameters
n.subjects <- 60 # how many simulated subjects to include
n.trials <- 30 # how many trials will each subject complete
prob.reward.A <- 0.8 # the probability of a positive reward for chosing option A
prob.reward.B <- 0.2 # the probability of a positive reward for chosing option B
reward.value <- 1 # the value of a positive reward

# model parameters
alpha <- 0.1 # controls the learning rate of the model
temperature <- 0.125 # controls the explore/exploit tradeoff of the decision rule

# implementing softmax ####

# the softmax decision rule is described in the README. implement the function here,
# returning the probability of selecting option A.

softmax.rule <- function(a.value, b.value, temperature){
  return(exp(a.value/temperature) / (exp(a.value/temperature) + exp(b.value/temperature)))
}

softmax.rule(a.value=2, b.value=1, temperature=1) # should be 0.731
softmax.rule(a.value=10, b.value=1, temperature=5) # should be 0.858

# model ####

# this function should run one subject through all trials.
# you should store the choice that the model makes and
# the model's probability of choosing option 'a' at each trial.
# at the end, you will return a data frame that contains this information.
# this part of the code has been provided to you.

# for the model, follow the description in the README file. 

run.one.subject <- function(){
  
  choices.history <- c() # please make sure that the values added to this are either 'a' or 'b'
  prob.a.history <- c()

  # ... your code to implement the reinforcement learning model goes here ...

  # start with Q values for A and B being 0
  q.a <- 0
  q.b <- 0
  
  # repeat the following for every trial in the experiment
  for(i in 1:n.trials){
    # determine the probability of choosing option A by applying the softmax function
    # to q.a and q.b.
    prob.a <- softmax.rule(a.value = q.a, b.value = q.b, temperature = temperature)
    # randomly choose a or b based on the prob.a given by the softmax above.
    choice <- sample(c('a','b'), 1, prob = c(prob.a, 1 - prob.a))
    # if the choice is a, generate a reward with probability prob.reward.A
    # and update q.a
    if(choice == 'a'){
      reward <- sample(c(reward.value, 0), 1, prob=c(prob.reward.A, 1-prob.reward.A))
      reward.prediction.error <- reward - q.a # remember that q.a is the expected reward
      q.a <- q.a + alpha * reward.prediction.error
    }
    # if the choice is b, generate a reward with probability prob.reward.B
    # and update q.b
    if(choice == 'b'){
      reward <- sample(c(reward.value, 0), 1, prob=c(prob.reward.B, 1-prob.reward.B))
      reward.prediction.error <- reward - q.b # remember that q.b is the expected reward
      q.b <- q.b + alpha * reward.prediction.error
    }
    # store the choice and probability
    choices.history <- c(choices.history, choice)
    prob.a.history <- c(prob.a.history, prob.a)
  }
  return(data.frame(trial=1:n.trials, choice=choices.history, probability=prob.a.history))
}

# if you've implemented the model above correctly, then running this block of code with the
# default parameters (30 trials, prob.reward.A = 0.8, prob.reward.B = 0.2, reward.value = 1, alpha = 0.1, temperature = 0.125)
# should produce a final probability of selecting option A on trial 30 of 0.9975339. the model will also, by strange coincidence,
# choose option 'a' for every trial.
set.seed(12604)
test.run.data <- run.one.subject()

# this code is provided to you to run multiple subjects, and aggregate their data into a single data frame
# note that it will cause R to display a WARNINGS message, but this is OK.
experiment.data <- NA # create variable to hold data.
for(s in 1:n.subjects){ # loop through each subject
  subject.data <- run.one.subject() # run the subject with a fresh model
  if(is.na(experiment.data)){ # if there is no data yet...
    experiment.data <- subject.data # ... then make this subject's data the experiment.data
  } else { # otherwise...
    experiment.data <- rbind(experiment.data, subject.data) # ... add this subject's data to the end of the set
  }
}

# this code uses the dplyr library to calculate the percentage of subjects who chose 'a' on each trial
# and to calculate the mean probability of selecting 'a' according to the model.
summarized.data <- experiment.data %>%
  group_by(trial) %>%
  summarize(choice_pct = sum(choice=="a")/n(), prob_mean = mean(probability))

# this code uses the ggplot2 library to make a plot similar to Figure 1 in the Pessiglione et al. (2006) paper.
ggplot(summarized.data, aes(x=trial, y=choice_pct))+
  geom_point()+
  geom_line(aes(y=prob_mean))+
  ylim(c(0,1))+
  labs(x="Trial Number", y="Modelled choices (%)")+
  theme_bw()

# QUESTIONS ####

# 1. Try running the model with different values for alpha and temperature. What is the effect of each parameter
#    on the final figure that is produced? Explain why these effects happen.

# ALPHA: If alpha is very high (say 0.8), then the model's behavior is more unstable (the line becomes more jagged).
#        This is because the model becomes overly responsive to whatever the most recent prediction error was, and
#        overcorrects for a rare event. If alpha is very low (0.01) the model's predictions are very stable, but the
#        model changes preference very slowly and the line has a small slope.

# TEMPERATURE: (Using alpha = 0.1 for these simulations.) When temperature is very low, the initial choice of the model
#              matters a LOT. If option B is selected and it happens to be a case where option B gets reward, then the
#              model will persist in choosing option B because its small expected reward is better than the reward of 0
#              for option A. This shows up in the average group data as plateau in the % of choices that are A. Some
#              subjects are just choosing B over and over because it was the first thing that was rewarded. 
#              Note that setting temperature too low (e.g., 0.001) creates problems because the numbers
#              get too large for the computer to represent and it resorts to "Inf" meaning positive infinity.

# 2. Pessiglione et al. also included a condition where the reward was negative instead of positive. They plot
#    the results as squares in Figure 1. Simulate this data. Can you match the general result? Why is the probability
#    curve in both Figure 1 and your simulation less smooth for this simulation than when the reward is positive?

# Parameters: Set reward value = -1, temperature = 0.08 (or somewhere around here). This shows a curve that looks pretty
# similar to the paper. The curve is bumpier than the positive reward because there are many fewer choices where the model
# selects the A option, because it is more likely to produce a negative reward. Therefore there's just less data to smooth
# the average. You can amplify this further by decreasing the number of subjects, since the original paper had fewer subjects
# than the 60 used above.

# 3. CHALLENGE (If you completed the rest of the lab relatively quickly, do this problem. If it took you plenty of
#    effort to complete the model, you can choose whether to pursue this problem or not.): 
#    In the paper, the authors use the model's reward prediction error to find brain regions that 
#    correlate with this signal. Modify the model to save the reward prediction error on each step. Then plot
#    the average reward prediction error for the 30 trials. Explain the shape of the graph. You may want to copy-and-paste
#    the model code into a new file to do this.

# SEE rpe-model.R

