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
temperature <- 0.08 # controls the explore/exploit tradeoff of the decision rule

# implementing softmax ####

# the softmax decision rule is described in the README. implement the function here,
# returning the probability of selecting option A.

softmax.rule <- function(a.value, b.value, temperature){
  return(exp(a.value*(1/temperature)) / (exp(a.value*(1/temperature))+exp(b.value*(1/temperature))))
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
  reward.prediction.error.history <- c()
  
  q.a <- 0
  q.b <- 0
  
  for(i in 1:n.trials){
    probability.of.a <- softmax.rule(q.a, q.b, temperature)
    
    choice <- sample(c('a','b'), size=1, prob = c(probability.of.a, 1-probability.of.a))
    choices.history <- c(choices.history, choice)
    if(choice == 'a'){
      reward <- sample(c(reward.value, 0), size=1, prob=c(prob.reward.A, 1-prob.reward.A))
      diff <- reward - q.a
      q.a <- q.a + alpha*diff
    }
    if(choice == 'b'){
      reward <- sample(c(reward.value, 0), size=1, prob=c(prob.reward.B, 1-prob.reward.B))
      diff <- reward - q.b
      q.b <- q.b + alpha*diff
    }
    reward.prediction.error.history <- c(reward.prediction.error.history, diff)
  }
  
  return(data.frame(trial=1:n.trials, choice=choices.history, reward.prediction.error=reward.prediction.error.history))
}

# if you've implemented the model above correctly, then running this block of code with the
# default parameters (30 trials, prob.reward.A = 0.8, prob.reward.B = 0.2, reward.value = 1, alpha = 0.1, temperature = 0.125)
# should produce a final probability of selecting option A on trial 30 of 0.9975339. the model will also, by strange coincidence,
# choose option 'a' for every trial.
#set.seed(12604)
test.run.data <- run.one.subject()

# this code is provided to you to run multiple subjects, and aggregate their data into a single data frame
# note that it will cause R to display a WARNINGS message, but this is OK.
experiment.data <- NA # create variable to hold data.
for(s in 1:n.subjects){ # loop through each subject
  subject.data <- run.one.subject() # run the subject with a fresh model
  subject.data$subject <- s # NEED TO ADD THIS TO THE MODEL FOR RPE, SO WE CAN PLOT INDIVIDUAL SUBJECT ERRORS
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
  summarize(choice_pct = sum(choice=="a")/n(), rpe_mean = mean(reward.prediction.error))

# this code uses the ggplot2 library to make a plot similar to Figure 1 in the Pessiglione et al. (2006) paper.
ggplot(summarized.data, aes(x=trial, y=choice_pct))+
  geom_line(data=experiment.data %>% filter(subject %in% 1:5), aes(x=trial, y=reward.prediction.error,group=factor(subject)), color="grey50")+
  geom_line(aes(y=rpe_mean), color="red", size=2)+
  ylim(c(-1,1))+
  labs(x="Trial Number", y="Reward Prediction Error")+
  theme_bw()

# QUESTIONS ####

# 3. CHALLENGE (If you completed the rest of the lab relatively quickly, do this problem. If it took you plenty of
#    effort to complete the model, you can choose whether to pursue this problem or not.): 
#    In the paper, the authors use the model's reward prediction error to find brain regions that 
#    correlate with this signal. Modify the model to save the reward prediction error on each step. Then plot
#    the average reward prediction error for the 30 trials. Explain the shape of the graph. You may want to copy-and-paste
#    the model code into a new file to do this.

# In the plot above, I'm showing the average reward prediction error (red line) and also the RPE for individual subjects.
# Note that the average RPE goes down steadily over the course of the experiment, but individuals show a lot of jumps in
# their RPE. This is because a reward of 0 occurs 20% of the time with option A, and yet the optimal strategy is to pick
# option A every time. So there will be periodic spikes in RPE. This signal is what the authors used to find brain
# regions that correlated with changes in RPE.