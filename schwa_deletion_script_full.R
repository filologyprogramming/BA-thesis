library(tidyverse)
library(lme4)
library(forcats)
library(viridis)
library(effects)
library(sjPlot)
schwa_deletion <- read.csv("schwa_deletion.csv")
View(schwa_deletion)



# Load parts of the tidyverse necessary for this bit of code.
# If you've loaded the entire tidyverse already,
# you don't have to load these separately
library(readr)
library(dplyr)

# Download subtlex-us frequency list from the internet
download.file(
  "http://crr.ugent.be/papers/SUBTLEX-US_frequency_list_with_PoS_information_final_text_version.zip",
  destfile = "SUBTLEX-US_frequency_list_with_PoS_information_final_text_version.zip"
)

# Unzip it
unzip("SUBTLEX-US_frequency_list_with_PoS_information_final_text_version.zip")

# Remove the ZIP file
file.remove("SUBTLEX-US_frequency_list_with_PoS_information_final_text_version.zip")

# Import subltex-us frequency list
subtlex_us <- read_tsv("SUBTLEX-US frequency list with PoS information text version.txt") %>%
  # Pick relevant info: Raw frequency
  select(Target.transcript = Word, frequency = FREQcount)

# Add data from subltex-us to your data
# Substitute 'data' with the name of the data frame with data in your project
proba <- left_join(schwa_deletion, subtlex_us, by = "Target.transcript")

# Pick only the columns needed
data_for_extraction <- schwa_deletion %>%
  mutate(
    start = ifelse(!is.na(Target.transcript.start) & Target.transcript.start - Line > 0.03,
      round(Target.transcript.start - 0.03, 2),
      Line
    ),
    end = ifelse(!is.na(Target.transcript.end) & LineEnd - Target.transcript.end > 0.03,
      round(Target.transcript.end + 0.03, 2),
      LineEnd
    )
  ) %>%
  select(Transcript, start, end, Number)


# Save the data frame as a CSV file to disk
write_csv(data_for_extraction, "for_extraction.csv")

# List all TextGrid files in the 'extracted' folder
textgrids <- list.files("extracted/", pattern = "TextGrid")


# Read each file into an object called 'tg'
for (i in 1:length(textgrids)) {
  tg <- readLines(file.path("extracted", textgrids[i]))

  # Change name of tier with segments to 'segments'
  tg <- str_replace_all(tg, 'name = "segments.*"', 'name = "segments"')

  # Change decimal mark from "," to "."
  tg <- str_replace_all(tg, "([:digit:]+),([:digit:]+)", "\\1.\\2")

  # Overwrite the original TextGrid file with the cleaned-up one
  write(tg, file.path("extracted", textgrids[i]))
}
warnings()

# List all files whose names you want to change
files <- list.files("extracted")

# Go through the files one by one, and ...
for (i in 1:length(files)) {
  # Get the prefix
  prefix <- str_extract(files[i], "^[:number:]+")
  # Get the extension
  extension <- str_extract(files[i], ".wav|.TextGrid")
  # Get the old name
  old_name <- file.path("extracted", files[i])
  # Construct the new name
  new_name <- file.path("extracted", paste(prefix, extension, sep = ""))
  # Rename the file
  file.rename(old_name, new_name)
}

################################################################

schwa_deletion %>%
  mutate(Outcome = fct_infreq(Outcome)) %>%
  ggplot(aes(Outcome)) +
  geom_bar() +
  labs(x = "Outcome", y = "")



###############################################################
write.csv(stlog, "stlog.csv")
stlog <- read.csv("stlog.csv")

schwa_with_log <- cut(stlog$x, breaks = 3)


# Get sound right before schwa (vowel or consonant),
# where the schwa is AFTER primarily stressed vowel in a word
# No NURSE,STRUT vowels, and no dyphtongs included
schwa_deletion_n_d <- as.tibble(schwa_deletion_n_d)

schwa_deletion_n_d %>% select(Text, Target.CMU_dictionary_stress) %>% 
  mutate(pre_schwa = str_extract(Target.CMU_dictionary_stress,
                                 ".. AH0 R|.. AH0 L|.. AH0 N")) %>% 
  View()

# Get sounds
open_vowels <- c("AA[012]", "AE[012]", "AO[012]", "AO[012]")
close_vowels <- c("EH[012]", "UH[012]", "UW[012]", "IY[012]", "IH[012]")
glides <- c("W", "Y")
liquids <- c("R", "L")
nasals <- c("M", "N", "NG")
fricatives <- c("F","V", "TH", "DH", "S", "Z", "SH", "ZH", "HH")
affricates <- c("CH", "JH")
plosives <- c("P", "T", "K", "B", "D", "G")
schwa_deletion_n_d <- schwa_deletion_n_d %>%
  mutate(log_frequency = (log(schwa_deletion_n_d$frequency)))

schwa_deletion_n_d_grouped <- schwa_deletion_n_d %>%
  mutate(frequency_grouped = cut(schwa_deletion_n_d$log_frequency, breaks = 3, labels = c("not_frequent", "moderately_frequent", "very_frequent")))

vowels <- c("AY1", "ER0", "IY0", "IY1", "UW2")
sonorants <- c("M", "N", "R", "Y", "ZH", "W")
fricatives <- c("F", "S", "SH", "TH", "V", "Z")
stops <- c("B", "CH", "D", "G", "JH", "K", "P", "T")

###########################################################

write.csv(schwa_deletion_n_d_grouped, file = "schwa_deletion_n_d_grouped.csv")



schwa_completed <- schwa_deletion_n_d_grouped %>%
  mutate(sonority_grouped = case_when(
    pre_schwa %in% vowels ~ "vowels",
    pre_schwa %in% sonorants ~ "sonorants",
    pre_schwa %in% fricatives ~ "fricatives",
    pre_schwa %in% stops ~ "stops",
  ))

write.csv(schwa_completed, file = "schwa_completed.csv")


# Extract rows without frequency
schwa_completed_2 <- schwa_completed %>%
  filter(frequency_grouped != "0")

schwa_completed_2 %>%
  mutate(sonority_grouped = fct_infreq(sonority_grouped))
ggplot(data = schwa_completed_2, aes(x = frequency_grouped, fill = Outcome)) +
  geom_bar(position = "dodge") +
  labs(x = "Frequency group", y = "") +
  scale_fill_viridis(discrete = TRUE, option = "C")




# Plot speech rate
ggplot(data = schwa_completed, aes(x = Outcome, y = syl_sec_EN)) +
  geom_boxplot() +
  labs(x = "", y = "Syllables per second")

###############################################
schwa_completed_2 %>%
  mutate(sonority_grouped = fct_infreq(sonority_grouped))

ggplot(data = schwa_completed_2, aes(x = sonority_grouped, fill = Outcome)) +
  geom_bar(position = "dodge") +
  labs(x = "Sonority class", y = "") +
  scale_fill_viridis(discrete = TRUE, option = "C")


# Plot sex
ggplot(data = schwa_completed_2, aes(x = participant_gender, fill = Outcome)) +
  geom_bar(position = "dodge", width = 0.5) +
  scale_fill_viridis(discrete = TRUE, option = "C") +
  labs(x = "Gender", y = "")

# Plot age

ggplot(data = schwa_completed_2, aes(x = participant_age_group, fill = Outcome)) +
  geom_bar(position = "dodge", width = 0.5) +
  scale_fill_viridis(discrete = TRUE, option = "C") +
  labs(x = "Age Group", y = "")

##################### CHAPTER3######################

schwa_completed_2$Speaker <- reorder(schwa_completed_2$Speaker, schwa_completed_2$Outcome, FUN = function(x) mean(as.numeric(x)))
ggplot(data = schwa_completed_2, aes(x = Speaker, fill = Outcome)) + # The value of 'Outcome' will be mapped as the color filling the bar
  geom_bar(position = "fill") +
  scale_fill_viridis(discrete = TRUE, option = "C") +
  theme_light() +
  labs(x = "Speaker", y = "") +
  coord_flip()


# Refactor variables
schwa_completed_2$Outcome <- as.factor(schwa_completed_2$Outcome)
schwa_completed_2$frequency_grouped <- as.factor(schwa_completed_2$frequency_grouped)
schwa_completed_2$sonority_grouped <- as.factor(schwa_completed_2$sonority_grouped)
schwa_completed_2$participant_gender <- as.factor(schwa_completed_2$participant_gender)
schwa_completed_2$participant_age_group <- as.factor(schwa_completed_2$participant_age_group)
schwa_completed_2$Speaker <- as.factor(schwa_completed_2$Speaker)



schwa_completed_2 <- schwa_completed_2 %>%
  select(
    Speaker, Outcome, frequency_grouped, syl_sec_EN,
    sonority_grouped, participant_gender, participant_age_group
  ) %>%
  group_by(Speaker) %>%
  mutate(syl_sec_EN = scale(syl_sec_EN))

############ relevel################

schwa_completed_2$Outcome <- fct_relevel(schwa_completed_2$Outcome, "n", "d")

levels(schwa_completed_2$Outcome)

schwa_completed_2$frequency_grouped <- fct_relevel(schwa_completed_2$frequency_grouped, "not_frequent", "moderately_frequent", "very_frequent")

# Create a model
model <- glmer(Outcome ~ frequency_grouped + syl_sec_EN + sonority_grouped + participant_gender + participant_age_group + (1 | Speaker), data = schwa_completed_2, family = "binomial", optimizer = "bobyqa")

summary(model)

plot(allEffects(model)[1])
plot(allEffects(model)[2])
plot(allEffects(model)[3])
plot(allEffects(model)[4])
plot(allEffects(model)[5])


tab_model(model,
  emph.p = TRUE,
  show.aic = TRUE,
  string.p = "p-value",
  file = "modelsummary"
)
