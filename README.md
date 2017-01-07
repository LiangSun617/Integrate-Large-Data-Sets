
## How to Aggregate and Integrate Large Data Sets: Experience from PSID Project

#### Liang Sun
#### October 15, 2016

This is my report of introducing and sharing my experience in dealing with large data sets at a student workshop at Penn State.  


#### All the data shown here are from public database, or fabricated for illustration purpose. No restricted data are leaked.

---

#### Outline
+ Understand the structure of your data
  + Two things: time and level
  + Example: PSID data
+ How to aggregate data of different levels
  + Research question
  + Read README
  + Find unique ID or key variables
  + Note time-variant variables
  + Merge and append files
+ How to aggregate data from different sources
  + Example 1: PSID + NCDB
  + Example 2: PSID + IPEDS
  + Example 3: PSID + Crosswalk + NCDB

---

### 1. Understand the structure of your data

* Choose data based on your research question

    Example 1: Does salary vary between people with and without college degree?

    Example 2: Is there a causal effect of financial aid policy on university's research output (comparing control group and treatment group)?

  *What kind of data will you use to answer each of the questions above?*

  For example 1, we use student-level data, because the groups we are comparing are formed by individuals. We can use data at a specific time point, or data across years for a longitudinal analysis.

  For example 2, we use institutional-level data, because we are comparing universities. In addition, the data should be longitudinal, so that we can compare the outcome before and after the policy was implemented.

- Sometimes, you need to design research questions based on the data that are available to you

- Two main things to consider: time, level.

    + Time: Are the data longitudinal? Are the variables time-variant?

    + Level: Unit of analysis

       + Individual-level data: Education Longitudinal Studies 2002 (ELS 2002)

       + Institutional-level data: Integrated Post-secondary Education System (IPEDS)

       + Family-level data: US Census IPUMS

       + Community/neighborhood-level data: Neighborhood Change Database (NCDB)

       + Country-level data: OECD, World Bank, UNESCO Institute for Statistics(UIS)



####  Example: Panel Study of Income Dynamics (PSID)

+ Introduction

  The study began in 1968 with a nationally representative sample of over 18,000 individuals living in 5,000 families in the United States. Information on these individuals and their descendants has been collected continuously, including data covering employment, income, wealth, expenditures, health, marriage, childbearing, child development, philanthropy, education, and numerous other topics.

  Year: 1968-1996, 1997 (2) 2013


+ Data structure

    + Single-year family file: 1968-1996, 1997 (2) 2013

        + Yearly family interview ID
        + Head/wife's demographic characteristics
        + Head/wife's education
        + Head/wife's income
        + Head/wife's occupation
        + Head/wife's parent's education, etc.

    + Individual file:

        + Single-year individual file: 1968-1996, 1997 (2) 2013
            + Yearly family interview ID, sequence number
            + Relation to head
            + Age
            + Marital status
            + Employment status, etc.
        + Cross-year individual file: constant over time
            + 1968 family interview ID
            + 1968 person number
            + Gender
            + Age of marriage
            + Time of first marriage, etc.

----

### 2. How to aggregate data of different levels

#### Research question: does one’s educational degree have impact on his/her choice of partner?

   What level of data should we focus on? Given our research question, we will need individual-level data since educational
   degree is individual characteristic. However, education is recoded as head/wife's eduation in family-level file in PSID. We
   will need to merge family-level and individual-level files so as to get an individual-level data set for analysis.


####  How to make the data become what we need?

   + Read README files and codebook  

    ![pic](/images/1.jpg)



  It is always helpful to read. This README file introduces the structure of the data and shows examples of how to merge or append data files. Large data sets like PSID usually provide detailed README file or manual.




To get the variables, you can browse online codebook which organizes variables by topic and year:

   ![pic3](/images/3.png)

You can also search variables directly in the database:

   ![pic2](/images/2.jpg)


   + Find unique ID that can be used to link files of different levels

        Variables may be coded differently in files of different levels, but they are very important for merging data. In PSID data, the key variable that links family and individual files is family interview number, which is coded differently not only across files, but also across years.

   ![pic4](/images/4.jpg)

    In the process, I renamed these variables into ID1968, ID1969,...,and so on, in both family and individual files.


   + Be careful with variables with names that have changed over time

        Again, the name of all variables in yearly files changes over time. It will be helpful if you can make a variable list on your own to record variable names of each year:

    ![pic5](/images/5.jpg)

####  Merge files

   To merge family and individual files, we need to use merge command. The software tool I used is Stata, and it is important to know how to use "merge" and "append" here.


+ Master data and using data

     ![pic](/images/6.jpg)

  Here I use family data file "FAM2013" as master data, and individual file "IND" as using data, and merge them on ID2013.

+ 1:1, 1:m, m:1, m:m

   Note that you may need to specify the relationship between two files on the key variable (depending on which version of Stata you are using). Is it one-to-one, one-to-multiple, or multiple-to-multiple relationship? In my case, I can also merge using m:1 by just switching master and using data:

   ![pic](/images/7.jpg)

+ Check "_merge"

   One thing I always do after merging is to check the system-generating variable "_merge" which reports how many observations are successfully merged and how many were not, and if not, which data file are they from.

   ![pic](/images/8.jpg)

#### Append files

  Different from "merge", "append" just simply attaches data files together by increasing observations, but without introducing new variables. Let's see some examples for a better understanding of the mechanism of these two commands.

+ Example 1: two completely different files (no overlapping values for all variables)

  ![pic](/images/9.jpg)

  ![pic](/images/10.jpg)

  ![pic](/images/11.jpg)

   If we merge these two files:

   ![pic](/images/12.jpg)

   ![pic](/images/13.jpg)

  We can see that "append" and "merge" seem to produce the same results; however, they are two different processes and "merge" created one more system variable "_merge".

+ Example 2: two files with overlapping ID values

  ![pic](/images/14.jpg)

  ![pic](/images/15.jpg)

  ![pic](/images/16.jpg)

If merge them:

 ![pic](/images/17.jpg)

 ![pic](/images/18.jpg)

Here, "merge" shows a much different result than "append", because when there is overlapping value for the key variable, "merge" will identify the common IDs. In this example, both files have ID 1,2,3,4. "Append" does not recognize the ID 1-4 in master data and using data as the same, and keep them separated in the result, while "merge" matches observations with these IDs and IDs remain unique after merging.

+ Two data files with overlapping values for ID variable and common variables

![pic](/images/19.jpg)

![pic](/images/20.jpg)

![pic](/images/21.jpg)

  If we merge them:

  ![pic](/images/22.jpg)

  We can see that "append" keeps all values from both master and using data, while "merge" only keeps the values of "odd" from the master data. This is because both files here have common IDs 1,2,3,4 and they both have a variable called "odd", so by merging the program has to decide from which side IDs 1-4 should take the value of "odd". In this case, the program always keeps the values from master data, which are 13,15,17,19 here.  

Once you get family and individual data files merged, you will get an individual-level data with unique observations which have characteristics from both files:

 ![pic](/images/23.png)

----

### 3. How to aggregate data from different sources

Like many other survey data sets, PSID focuses on socioeconomic characteristics of households; however, we often want to broaden our view and come up with research questions that invovle other aspects of social life. In fact, many large social data sets, especially those sponsored by governments, have considered the possibility of linking to each other, so that researchers can make best use of the social resources.  

In our PSID project, we need to consider more variables that are not in PSID.

 + Example 1: Does the percentage of college-educated residents in one's neighborhood have impact on his/her choice of partner in terms of education attainment?
 + Example 2: Does the quality of college one attends have impact on his/her choice of partner?

To answer the first question, we will need a measurement of educated population of neighhoods in the United States, in addition to what is available there in PSID restricted data, particularly the geographic CBSA (Core-Based Statistical Area) codes for each household.

To answer the second question, we will need another measurement of college quality, although we have information about which college respondents attended in PSID-IPEDS restricted data.

Through research, we decide to link two external data sets to PSID:

   + NCDB: Neighborhood Change Database, which reports the demographics in the unit of neighborhood from 1970 to 2010. It contains a variety of neighborhood ID indicators, including FIPS codes, MSA codes, and CBSA codes. We will use CBSA codes to link NCDB to PSID.

   + IPEDS: Integrated Postsecondary Education System, which contains institutional-level characteristics of over 7,000 colleges and universities in the United States, including information on student admission, graduation, achievement, faculty, finance and so on. It also reports the average SAT scores of new students of institutions since 2001. We will use SAT scores to measure college quality and link IPEDS data to PSID on institution ID.

#### Example 1: PSID + NCDB

 + What do they have in common?

     + They both have geographic indicator - CBSA

 + What is their difference?

     + They have different data structure.

         + PSID is individual-level and wide format

         + NCDB is neighborhood-level and long format

+ Wide format vs. long format

 Command to convert format:

 ![pic](/images/24.jpg)

 Long format:

 ![pic](/images/25.jpg)

 wide format:

 ![pic](/images/26.jpg)

 In long format, there are multiple records for each ID, which means ID cannot uniquely identify a unit. In NCDB, the unit of analysis is CBSA area,and for each CBSA area, there are two records, one for 2009 and one for 2010.
 In wide format, each CBSA area has only one record, with variables being named XX2009, XX2010.
 By converting NCDB data from long format to wide format, we prepare it for merging with PSID data which are also in wide format.

#### Example 2: PSID+IPEDS

 + What do they have in common?

     + They both have Institution ID.

 + What is their difference?

     + They have different data structure.

         + PSID is individual-level and wide format

         + IPEDS is institutional-level and long format

+ Convert PSID from long format into wide format

    Long format:

    ![pic](/images/27.jpg)

  Codes:

  ```
  reshape wide instnm control satvr25 satvr75 satmt25 satmt75,i(unitid)j(year)

  ```

   + "reshape wide" is the command for converting long into wide format.
   + "instnm" is institutional name.
   + "control" refers to whether the institution is private or public.
   + "satvr" are the 25% and 75% of verbal and math SAT test scores.
   + "unitid" is the ID; "i(unitid)" specifies which variable is the key ID variable.
   + "j(year)" attaches the values of year to each of the variables listed here, for example, "control" will become      "control2009","control2011",and "control2013", so that each unitid will have only one record in the data.


 Wide format:

 ![pic](/images/28.jpg)

#### Example 3: PSID + crosswalk + NCDB

Sometimes, it may be hard to find any key variable between two data sets. For example, many PSID families do not have CBSA code. If we merge PSID with NCDB on CBSA code, then we will have a large number of missing values afterwards. Therefore, we may want to try other variables that have better quality and can retain more observations in the merging process.

One thing I found is that PSID also has FIPS codes, which are based on state code and county code. In such case, we can make and use a crosswalk file like this:

![pic](/images/29.jpg)

We can convert the FIPS codes into CBSA in PSID file and then merge with NCDB on CBSA.

In fact, FIPS codes have broader coverage than CBSA codes do in geography, because CBSA was made for statistical analysis of areas with population above certain level and neglected rural and distant areas. Most families with missing CBSA codes in PSID probably not lie in any CBSA area, so even using a crosswalk file cannot get them valid CBSA codes. However, introducing crosswalk file here can provide us an idea of dealing with the problem we might come across when aggregating data sets from different sources.

---

#### Useful tips

+ FIPS: Federal Information Processing Standard codes which uniquely identifies counties and county equivalents in the United States, certain U.S. possessions, and certain freely associated states.

    You can always search online for existing crosswalk files, such as:
    CBSA to FIPS County Crosswalk
    http://www.nber.org/data/cbsa-fips-county-crosswalk.html

    Or look up any specific code:
    http://county-codes.findthedata.com/


+ PSID https://psidonline.isr.umich.edu/

+ IPUMS: Integrated Public Use Microdata Series    https://usa.ipums.org/usa/

+ NCDB: Neighborhood Change Database   http://www.geolytics.com/USCensus,Neighborhood-Change-Database-1970-2000,Products.asp

+ UIS: UNESCO Institute for Statistics    http://www.uis.unesco.org/Education/Pages/default.aspx
