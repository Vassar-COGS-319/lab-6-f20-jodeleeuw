# let's say you want to pick one of two options randomly, but you don't want
# the probability of picking option A to be the same as picking B. the sample()
# function can do this by using the prob= argument.

choice <- sample(c('a','b'), 1, prob=c(0.8, 0.2))

# the above code will select 1 sample from the set c('a','b'). the probability
# of choosing 'a' is 0.8 and the probability of choosing 'b' is 0.2.

# one weird thing about this function: the set of probabilities doesn't have to add to 1.
# if they don't add to 1, R will normalize the values so that they sum to 1. this can be helpful
# when you are thinking about frequency rather than probability. say you want item 'a' to be chosen
# 10x more often than item 'b'. you can write:

choice <- sample(c('a','b'), 1, prob=c(10, 1))

# problem:
# write a sample function that chooses among three options ('a','b','c'). the probability
# of choosing 'a' should be 0.5, 'b' should be 0.3, and 'c' 0.2. generate 1,000 samples (HINT:
# sample WITH replacement). store the choices in a variable called 'choices'.

# now, look up the table() function and the barplot() function. use them together to create
# a bar graph that visualizes the number of times each option was selected.
