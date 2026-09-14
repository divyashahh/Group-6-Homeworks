# Homework 2 - Tomas Rinne individual

pretrt <- c(130, 128, 116, 124, 133, 134, 118, 126, 114, 127, 141, 138, 128, 140, 137, 131, 120, 128, 139, 135)
posttrt <- c(114, 98, 113, 99, 107, 116, 113, 111, 119, 117, 101, 119, 130, 122, 106, 106, 124, 102, 117, 113)

subject_ids <- paste("Subject", 1:20, sep = "_")

names(pretrt) <- subject_ids
names(posttrt) <- subject_ids

prepostdiff <- c(pretrt - posttrt)

avgdiff <- mean(prepostdiff)

DecreaseBP <- which(prepostdiff > 0)

avgDecrease <- mean(DecreaseBP)


