directory="/Volumes/Macintosh/System/Volumes/Data/Physics/Quantum Mechanics/EPR/epr_investigations/violation_of_bell_inequality/longdist35/"
data <- as.numeric (read.csv(paste0(directory, "alice_timetags/OEM_0.csv"), header = FALSE))

print(paste("Is vector", is.vector(data)))
print(paste("number of items", length(data)))

print(summary(data))

result.mean <- mean(data)
print (paste("Mean:", result.mean))

result.var <- var(data)
print (paste("Variance:", result.var))

df_data = as.data.frame(data)
print(summary(df_data))
