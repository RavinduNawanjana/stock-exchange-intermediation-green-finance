README
Supplementary Data for Journal Submission
================================================================

This repository contains the survey dataset and statistical analysis
output supporting the conclusions reported in the associated manuscript.

--------------------------------------------------------------
FILES INCLUDED
--------------------------------------------------------------

1. Dataset_S1_Raw_Survey_Data.xlsx
   Raw item-level survey responses (Excel format), two sheets:
     - "Codebook": variable code, construct/section, and full question
       text for each of the 30 items.
     - "Raw_Data": 103 respondents (rows) x 30 items, V1-V30, each
       measured on a 5-point Likert scale (1 = Strongly Disagree ...
       5 = Strongly Agree).
   Item-to-construct mapping (see the Codebook sheet for full question
   wording):
     V1-V7:   Policy and Regulatory Alignment (7 items)
     V8-V14:  Market Mechanisms (7 items)
     V15-V21: Market Awareness (7 items)
     V22-V28: Market Incentives (7 items)
     V29-V30: Green Finance Adoption (outcome variable, 2 items)

2. Dataset_S2_SPSS_Data_File.sav
   The working IBM SPSS Statistics data file used for all analyses
   reported in the manuscript: the same 30 raw items as Dataset_S1
   (V1-V30, 103 cases), plus the composite (mean) scale scores used in
   the regression analysis:
     PRA_MEAN  - Policy and Regulatory Alignment (composite)
     MM_MEAN   - Market Mechanisms (composite)
     MA_MEAN   - Market Awareness (composite)
     MI_MEAN   - Market Incentives (composite)
     GFA_MEAN  - Green Finance Adoption (composite, dependent variable)
   and standard SPSS-generated regression diagnostic variables
   (unstandardized/standardized residuals, Mahalanobis distance, Cook's
   distance, leverage values) for the regression models reported.

3. Dataset_S3_SPSS_Output.spv
   The full IBM SPSS Statistics output viewer file (readable in SPSS
   Statistics), containing, in order:
     - Descriptive statistics
     - Reliability analysis (Cronbach's alpha) for each of the five
       scales
     - Exploratory Factor Analysis (KMO and Bartlett's test,
       communalities, total variance explained, factor/pattern/
       structure matrices)
     - Composite Reliability (CR) and Average Variance Extracted (AVE)
       calculation
     - Case processing summary / exploratory data checks
     - Correlation analysis (Pearson and non-parametric)
     - Multiple linear regression analysis (model summary, ANOVA,
       coefficients, collinearity diagnostics) with bootstrapped
       estimates
     - Final descriptive statistics

4. README.txt
   This file.

--------------------------------------------------------------
DATA COLLECTION AND ETHICS
--------------------------------------------------------------

Primary data were collected via a structured questionnaire administered
to financial practitioners. Participation was voluntary and anonymous;
informed written consent was obtained from all participants prior to
data collection. The research protocol was reviewed and approved in
accordance with the university's ethics procedures and conducted in
compliance with the Declaration of Helsinki (1964) and its later
amendments. No personally identifying information was collected as
part of the questionnaire, and none is contained in the files above.
Data were processed in accordance with the UK Data Protection Act 2018
and the General Data Protection Regulation (GDPR).

Secondary data referenced in the manuscript are derived from publicly
available sources (stock exchange, regulatory authority, and
international financial institution reports/databases) and are cited
within the manuscript itself; they are not reproduced here.

--------------------------------------------------------------
SOFTWARE
--------------------------------------------------------------

Analyses were conducted in IBM SPSS Statistics (version 31). The .sav
file can be opened directly in SPSS Statistics; the .spv file requires
IBM SPSS Statistics (or the free IBM SPSS Statistics Viewer) to open.
The .xlsx file can be opened in Microsoft Excel or any compatible
spreadsheet application.

--------------------------------------------------------------
FILE CONSISTENCY
--------------------------------------------------------------

Dataset_S1 and Dataset_S2 now contain the same 30 items (V1-V30) for
the same 103 cases, so the raw data and the SPSS working file are
fully aligned; Dataset_S2 additionally carries the composite scores
and regression diagnostics generated during analysis.

================================================================
