# Summary of BA thesis

One of the many connected speech processes, schwa deletion, is very frequent in conversa-
tional American English. It occurs in different environments and positions in the tokens. In
American English in three- and more syllable words post-stress schwa undergoes deletion
before /r, l, n/ sounds optionally e.g. family, actually or realize, and the process is not al-
ways present. Zwicky (1972) states that the schwa deletion is the most frequent before /r/
yet he does not explicitly explain why. This paper will not try to find the answer to this
state of affairs.
The main purpose of this study is to determine what factors contribute to post-stress
schwa deletion before /r, l, n/, and which are the most influential. The factors which were
chosen as hypothetically significant were lexical frequency, sonority difference between
sounds next to schwa, speech rate, sex, and age.
The hypothesis was that the greater the lexical frequency of a token the greater the
probability of schwa deletion and this variable was chosen as the main one.
The study was based on the recordings from the Buckeye Corpus (Pitt et al. 2007)
which contains a big sample of speech, namely, almost 40 hours. The corpus was uploaded
to a LaBB-CAT platform (Fromont and Hay 2012) which in addition to the orthographic
and pronunciation layers from Buckeye added the new ones e.g. with automatically calcu-
lated speech rate. By using regular expressions 2282 token were retrieved via LaBB-CAT
and coded as useful for the further consideration or not. Additionally, it was crucial to code
the sonority. Out of each token, the preceding sound was taken and put into one of the four
groups: “vowels”, “sonorants”, “fricatives”, and “vowels”.
The deeper analysis of tokens was done in RStudio (RStudio Team 2016), an open
source program for statistical computing, which uses R (R Core Team 2018) as an opera-
tional language. Preliminary analysis showed that, indeed, the greatest number of deletions
occurred in high-frequency words. Additionally, the higher speech contributed to the dele-
tion.
To check which factors are statistically significant, and influence post-stress schwa
deletion before /r, l, n/ it was necessary to run a logistic regression model. It showed that
the predictors high-frequency of a token, speech rate, and sonority group – sonorants are
statistically significant. The variables sex and age were found as not statistically significant.
