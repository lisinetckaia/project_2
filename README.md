# project_2
Project : Data Science Jobs Analysis 
This project aims to conduct comprehensive analysis on data scientist employment trends and salaries, in order to offer valuable insights for decision-making and strategic planning for anyone seeking employment in the industry. Furthermore, it provides essential information for corporations to establish competitive salary aligned with industry standards and regional variations.

In this Project I'm using 2 different data sets for my analysis: 
1) Data from Glassdoor from 2017 -2018: https://www.kaggle.com/datasets/thedevastator/jobs-dataset-from-glassdoor/data
2) Data Scientists salaries in 2024 : https://www.kaggle.com/datasets/thedevastator/jobs-dataset-from-glassdoor/data

**First Dataset has the following variables:** 

  * Job.Title: Title of the Job
  * Salary.Estimate: Salary range for the job
  * Job.Description: The description of the job
  * Rating: Rating of the company on Glassdoor
  * Company.Name: Name of the Company
  * Location: Location of the job (City and State)
  * Headquarters: Headquarters of the company
  * Size: Number of employees in the company
  * Founded: The year the company was founded
  * Type.of.ownership: Ownership types like private, public, government, and non-profit organizations
  * Industry: Industry type like Aerospace, Energy where the company provides services
  * Sector: Which type of services company provide in the industry, like industry (Energy), Sector (Oil, Gas)
  * Revenue: Total revenue of the company
  * Competitors: Company competitors
  * hourly: is the salary provided hourly ( 1 for yes, 0 for no)
  * employer_provided: is the salary range listed provided by employer
  * min_salary: lowest range of salary from Salary.Estimate
  * max_salary: highest range of salary from Salary.Estimate
  * avg_salary: average is (min_salary+max_salary)/2
  * company_txt: Name of the company without rating next to it
  * job_state: The state where the job is located (String)
  * same_state: A binary indicator of whether the job is in the same state as the company headquters (Numeric)
  * age: The age of the company in 2023 (Numeric)
  * python_yn: A binary indicator of whether the person looking at the job knows Python (Numeric)
  * R_yn: A binary indicator of whether the person looking at the job knows R (Numeric)
  * spark: A binary indicator of whether the person looking at the job knows Spark (Numeric)
  * aws: A binary indicator of whether the person looking at the job knows AWS (Numeric)
  * excel: A binary indicator of whether the person looking at the job knows Excel (Numeric)
  * job_simp: A simplified job title (String)
  * seniority: The seniority level of the job posting (String)
  * desc_len: The length of the job description (Numeric)
  * num_comp: The number of competitors for the company (Numeric)


**Second Dataset has the following variables:**
  * work_year:The year in which the data was collected (2020-2024, mostly 2023 and 2024)
  * experience_level: The experience level of the employee, typically categorized as entry-level (EN), mid-level (MI), senior-level (SE) or executive-level (EX)
  * employment_type: The type of employment, such as full-time (FT), part-time (PT), contract (CT), or freelance (FL).
  * job_title: The title or role of the employee within the company, for example, Data Scientist.
  * salary: The salary of the employee in the local currency (e.g., 120,000 AUD).
  * salary_currency: The currency in which the salary is denominated (e.g., USD or AUD).
  * salary_in_usd: The salary converted to US dollars for standardization purposes.
  * employee_residence: The country of residence of the employee.
  * remote_ratio: The ratio indicating the extent of remote work allowed in the position (0 for no remote work, 1 for fully remote).
  * company_location: The location of the company where the employee is employed. (Mostly US and Canada) 
  * company_size: The size of the company, often categorized by the number of employees (S for small, M for medium, L for large).

My Project Aims to provide answers to the following questions:

  * Which factors most effect data science salaries 
  * Which states and cities offer the highest paying data science jobs
  * In which industry do data scientists get paid the most
  * Private Company vs Public Company: which one pays more?

    






