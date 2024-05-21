library(dplyr)
library(ggplot2)
library(tidyr)
library(reshape2) # reshaping the data 
library(corrplot) # correlation matrix 
library(car) # applied regression 
data_1 <- read.csv(file = "./salary_data_cleaned.csv") #  Glassdoor data
data_2 <- read.csv(file = "./glassdoor_jobs.csv") #  Glassdoor data 
data_3 <- read.csv(file = "./eda_data.csv") #  data science job postings from Glassdoor.com for 2017-2018 (33 variables)
data_4 <- read.csv(file = "./salaries_2.csv")  # data scientist salaries for 2024


# checking for missing values in each dataframe 
sum(is.na(data_1))
sum(is.na(data_2))
sum(is.na(data_3))
sum(is.na(data_4))



# check if there are empty strings and replace them with NA
# dplyr::mutate_all(data_1, list(~na_if(.,"")))
data_1 %>% dplyr::mutate_if(is.character, list(~na_if(.,""))) 
data_2 %>% dplyr::mutate_if(is.character, list(~na_if(.,""))) 
data_3 %>% dplyr::mutate_if(is.character, list(~na_if(.,""))) 
data_4 %>% dplyr::mutate_if(is.character, list(~na_if(.,""))) 
sum(is.na(data_1))
sum(is.na(data_2))
sum(is.na(data_3))
sum(is.na(data_4))

# dropping column X from data_3
data_3 <- data_3 %>% select(-X)
summary.data.frame(data_3)

# how many different companies are in data_1
length(unique(data_1$company_txt))
# how many different industies in data_1
length(unique(data_1$Industry))
# how many different sectors in data_1
length(unique(data_1$Sector))
# how many different job titels in data_1
length(unique(data_1$Job.Title))
# how many different states in data_1
length(unique(data_1$job_state))

# there are some hourly salaries mixed in with yearly, we need to convert it in column avg_salary, it's correct in min_salary and max_salary
table(data_3$hourly)
h_to_y <- function(data) {
  hourly = data$hourly == 1
  data$avg_salary[hourly] <- (data$min_salary[hourly] + data$max_salary[hourly])/2
  return(data)
}
data_1 <- h_to_y(data_1)
data_3 <- h_to_y(data_3)

# heat map to see the correlation between variables 
# create a subset for data_1 with numeric variables only

data_numeric <- select_if(data_1, is.numeric) 

data_numeric <- data_numeric[, !names(data_numeric) %in% c("Founded","hourly", "employer_provided", "same_state", "age")]

# data_melted <- melt(data_numeric)

# correlation matrix 
cor_matrix <- cor(data_numeric)
cor_melted <- melt(cor_matrix, varnames = c("Var1", "Var2"), value.name = "Correlation")

ggplot(data = cor_melted, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile() +
  labs(title = "Correlation Heatmap",
       x = "Variable",
       y = "Variable") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)) +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name = "Correlation") +
  geom_text(aes(label = round(Correlation, 2)), color = "black", size = 2)


# rate of different skills required 
python_jobs <- data_1[data_1$python_yn ==1, ]
rate_python = ((nrow(python_jobs))/nrow(data_1))*100

r_jobs <- data_1[data_1$R_yn ==1, ]
rate_r = ((nrow(r_jobs))/nrow(data_1))*100

spark_jobs <- data_1[data_1$spark ==1, ]
rate_spark = ((nrow(spark_jobs))/nrow(data_1))*100

aws_jobs <- data_1[data_1$aws ==1, ]
rate_aws = ((nrow(aws_jobs))/nrow(data_1))*100

excel_jobs <- data_1[data_1$excel == 1, ]
rate_excel = ((nrow(excel_jobs))/nrow(data_1))*100

# plot Required skills rate
skills_data <- data.frame(
  skill = c("Python", "R", "Spark", "AWS", "Excel"),
  rate = c(rate_python, rate_r, rate_spark, rate_aws, rate_excel)
)
ggplot(skills_data, aes(x = skill, y = rate, fill = skill)) +
  geom_bar(stat = "identity")+
  theme_light()+
  labs(title = "Skills Required", x = "Skill", y = "Rate (%)") +
  geom_text(aes(label = paste0(round(rate, 1), "%")), 
            position = position_stack(vjust = 0.5),size=3)


# multiple skills vs salary 
# 2 skills vs 3 skills vs 4 skills
# how many skills in each row are true, create new column 
filter_skills <- function(data, skill_count) {
  data %>%
    rowwise() %>%
    mutate(skill_count = sum(c_across(c(python_yn, R_yn, spark, aws, excel)) == 1)) %>%
    ungroup() 
  
}

# plot how number of skills is correlated with the salary 
data_skills <- filter_skills(data_1) %>%
  filter(skill_count >= 0 & skill_count <= 5)
ggplot(data_skills, aes(x = factor(skill_count), y = avg_salary)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = paste(i, "Number of skills vs Salary"), 
       x = "Number of Skills", 
       y = "Average Salary(thousands)")+
  theme(plot.title = element_text(hjust = 0.5))


# create a subset of variables that might effect the salary
data_processed <- data_3 %>%
  select(Rating, avg_salary, job_simp, job_state, python_yn, R_yn, spark, aws, excel, Industry, Revenue)

# convert categorical variables to factors
data_processed$job_simp <- as.factor(data_processed$job_simp)
data_processed$job_state <- as.factor(data_processed$job_state)
data_processed$Industry <- as.factor(data_processed$Industry)
data_processed$Revenue <- as.factor(data_processed$Revenue)
data_processed$python_yn <- as.factor(data_processed$python_yn)
data_processed$R_yn <- as.factor(data_processed$R_yn)
data_processed$spark <- as.factor(data_processed$spark)
data_processed$aws <- as.factor(data_processed$aws)
data_processed$excel <- as.factor(data_processed$excel)

# linear regression model 
model <- lm(avg_salary ~ Rating + job_simp + job_state + python_yn + R_yn + spark + aws + excel + Industry + Revenue, data = data_processed)
summary(model)


# residual plot: Residuals vs Fitted
ggplot(model, aes(.fitted, .resid)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  labs(title = "Residuals vs Fitted", x = "Fitted values", y = "Residuals") +
  theme_minimal()

# Normal Q-Q to see normal distribution 
ggplot(model, aes(sample = .stdresid)) +
  stat_qq() +
  stat_qq_line() +
  labs(title = "Normal Q-Q", x = "Theoretical Quantiles", y = "Standardized Residuals") +
  theme_minimal()

# Scale-Location to see constant variance assumption in regression analysis
ggplot(model, aes(.fitted, sqrt(abs(.stdresid)))) +
  geom_point() +
  geom_smooth(se = FALSE) +
  labs(title = "Scale-Location", x = "Fitted values", y = "Square Root of Standardized Residuals") +
  theme_minimal()

# Residuals vs Leverage to see outliers and influential observations 
ggplot(model, aes(.hat, .stdresid)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  labs(title = "Residuals vs Leverage", x = "Leverage", y = "Standardized Residuals") +
  theme_minimal()

# rating vs average salary
ggplot(data_processed, aes(x = Rating, y = avg_salary)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Effect of Rating on Avg Salary", x = "Rating", y = "Average Salary") +
  theme_minimal()

# job title vs salary
ggplot(data_processed, aes(x = job_simp, y = avg_salary)) +
  geom_boxplot() +
  labs(title = "Effect of Job Title on Salary", x = "Job Title", y = "Average Salary") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# job state vs salary 
ggplot(data_processed, aes(x = job_state, y = avg_salary)) +
  geom_boxplot() +
  labs(title = "Effect of Job State on Avg Salary", x = "Job State", y = "Average Salary") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

# regression plot with number of skills requred 
ggplot(filtered_data, aes(x = skill_count, y = avg_salary)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Number of Skills vs Salary", x = "Number of Skills", y = "Average Salary") +
  theme_minimal()
table(data_3$seniority)
# group by industry and senioity to find average salary for each seniority level
industry_salary <- data_3 %>%
  group_by(Industry, seniority) %>%
  summarize(avg_salary = mean(avg_salary, na.rm = TRUE)) %>% ungroup()

# top 10 highest salaries for senior positions
top_senior <- industry_salary %>%
  filter(seniority == "senior") %>%
  arrange(desc(avg_salary)) %>% slice_head(n=10)
# top 10 salaries for jr or non specified positions
top_non_senior <- industry_salary %>%
  filter(seniority == "jr" | seniority == "na" ) %>%
  arrange(desc(avg_salary)) %>% slice_head(n=10)

industry_salary %>%  slice(3:18) %>%
  ggplot(aes(x = Industry, y = avg_salary, fill = seniority)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Salary by Industry and Seniority", x = "Industry", y = "Average Salary") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# there is one entry in column job_state that has Los Angeles instead of CA,so we need to fix that
data_1 <- data_1 %>%
  mutate(job_state = ifelse(job_state == " Los Angeles" | job_state == "CA", " CA", job_state)) 

# check
unique(data_1$job_state)

highest_salary <- data_1 %>%
  arrange(desc(avg_salary))
# plot of highest salaries per State
highest_salary %>% 
  ggplot(aes(x = job_state, y = max_salary)) +
  geom_bar(stat = "identity", fill = "orange")  +
  labs(title = "Highest Salaries by State", x = "State", y = "Salary") +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5))

# plot of highest salaries per City
highest_salary %>% 
  slice_head(n=30) %>%
  ggplot( aes(x = Location, y = max_salary)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(title = "Highest Salaries by City", x = "State", y = "Salary") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

table(data_3$Type.of.ownership)
filtered_data <- data_3 %>%
  filter(Type.of.ownership %in% c("Company - Private", "Company - Public","Government", "Nonprofit Organization")) %>%
  group_by(Type.of.ownership) %>%
  summarize(avg_salary = mean(avg_salary))

filtered_data %>%
  ggplot(aes(x = Type.of.ownership, y = avg_salary, fill = Type.of.ownership)) +
  geom_bar(stat = "identity") +
  labs(title = "Salary by Ownership Type", x = "Type of Ownership", y = "Average Salary") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# average Pay per State (for 20 States)
data_1 %>%
  group_by(job_state) %>%
  summarize(avg_salary = mean(avg_salary)) %>%
  arrange(desc(avg_salary)) %>%
  slice_head(n=20) %>%
  ggplot(aes(x = reorder(job_state, avg_salary), y = avg_salary, fill = job_state)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Salary by State", x = "State", y = "Average Salary") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# remove states with 1 entry of with repeating entries
state_data <- data_1 %>%
  filter(!(job_state %in% c(" KS", " DE", " SC", " RI"))) 
# function that creates violin plots for each state
state_salary <- function(state_name) {
  state_data <- data_1 %>%
    filter(job_state == state_name) 
  
  ggplot(state_data, aes(x = job_state, y = avg_salary, fill = job_state)) +
    geom_violin() +
    labs(title = paste("Salary Range in", state_name), x = "State", y = "Salary") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
  
}
# separate plots for each state
state_plots <- lapply(unique(state_data$job_state), state_salary)
state_plots

# check why certain plots didn't work 
wrong_entries <- data_1 %>%
  filter(job_state == " KS" | job_state ==" DE" |job_state == " SC" |job_state == " RI")
print(wrong_entries)

# check all the unique values for Revenue 
# table(data_3$Revenue)

# revenue categories with the most entries 
revenue_categories <- c(
  "$50 to $100 million (USD)",
  "$100 to $500 million (USD)",
  "$500 million to $1 billion (USD)",
  "$1 to $2 billion (USD)",
  "$10+ billion (USD)"
)

# filter data and create plot 
data_3 %>% filter(Revenue %in% revenue_categories) %>%
  ggplot(aes(x = Revenue, y = avg_salary, fill = Revenue)) +
  geom_boxplot() +
  labs(
    title = "Salary Distribution by Company Revenue",
    x = "Company Revenue",
    y = "Average Salary"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 12, face = "bold", vjust = 2),
        plot.margin = margin(5,0,0,10),
        legend.text = element_text(size = 9)
  )
data_3 %>% group_by(Sector) %>%  filter(!(Sector == -1)) %>%
  summarize(avg_salary = mean(avg_salary)) %>%
  arrange(desc(avg_salary)) %>% slice_head(n=10) %>%
  ggplot(aes(x = Sector, y = avg_salary)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Highest Salaries by Sector",
       x = "Sector",
       y = "Salary") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


table(data_4$work_year)
table(data_4$company_size)
# plot salary by employment type
data_4 %>%
  group_by(employment_type) %>%
  summarize(avg_salary = mean(salary_in_usd)) %>%
  ggplot(aes(x = employment_type, y = avg_salary)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(title = "Average Salary by Employment Type",
       x = "Employment Type",
       y = "Average Salary (USD)") +
  theme_minimal()+
  scale_x_discrete(labels = c("FT" = "Full-time", "PT" = "Part-time", "CT" = "Contract", "FL" = "Freelance"))


# Salary by company size and experience level 
data_4 %>%  
  group_by(experience_level, company_size) %>% summarize(avg_salary = mean(salary_in_usd),.groups = "drop") %>%
  ggplot() +
  geom_bar(mapping = aes(x= company_size, y= avg_salary, fill =avg_salary),
           stat = "identity", position = "dodge") +
  labs(title = "Salary for Experience level by Company Size", x = "Company Size", y= "Salary in USD") +
  facet_wrap(~experience_level, nrow = 1) +
  scale_y_discrete(labels = scales::comma) +
  scale_fill_continuous(labels = scales::comma) +
  scale_x_discrete(labels = c("EN" = "entry-level", "EX" = "executive-level", "MI" = "mid-level", "SE" = "executive-level"))


data_4 %>% 
  group_by(experience_level) %>% summarize(avg_salary = mean(salary_in_usd), .groups = "drop") %>%
  ggplot(aes(experience_level, avg_salary, fill=avg_salary))+
  geom_bar(stat = "identity", na.rm = T )+
  labs(title = "2020-2024 Salary by Experience Level", x = "Experience Level", y = "Salary (US Dollars)")


data_4 %>% 
  group_by(experience_level, work_year) %>% 
  summarize(avg_salary = mean(salary_in_usd), .groups = "drop") %>%
  ggplot(aes(experience_level,avg_salary , fill=avg_salary))+
  geom_bar(stat = "identity", na.rm = T )+
  labs(title = "Salary per year by Experience Level", x = "Experience Level", y = "Salary (US Dollars)")+
  facet_wrap(~work_year)+
  theme(legend.position="none",
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())




