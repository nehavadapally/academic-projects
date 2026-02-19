/* ****************************** 1.IMPORTING THE DATASETS ************************************ */
FILENAME sform '/home/u64180336/CH_data/6form.csv';

LIBNAME CH_data '/home/u64180336/CH_data';
DATA CH_data.sixthFormCollege;
	INFILE sform DSD DLM=',' firstobs =2 MISSOVER; 
		INPUT
	        Total_CH_Year1 		:	9.
	        Learners1 			:	8.
	        Total_CH_Year2 		:	9.
	        Learners2 			:	8.
	        Total_CH_Year3 		:	9.
	        Learners3 			:	8.
	        GradPR 				:	BEST8.
	        VAF					:	BEST8.
	        InstitutionType		:	$CHAR50.
	        Region 				:	$CHAR50.
	        GPercentFemale 		:	8.
	        ;
RUN ;

PROC IMPORT DATAFILE='/home/u64180336/CH_data/FEmetric02.tab'
	OUT=FE_Metrics
	DBMS=TAB
	REPLACE;
	GETNAMES=YES;
	DATAROW=2;
RUN;

%MACRO read_data(file=, out=);
   DATA &out.;
      INFILE "&file." DSD DLM=',' FIRSTOBS=2 MISSOVER;
      INPUT 
      		ID				: 8.
      		InstitutionType	: $CHAR50.
      		Region			: $CHAR50.
      		Total_CH_Year1	: 9.
      		Learners1 		: 9.
      		Total_CH_Year2 	: 9.
      		Learners2 		: 9.
      		Total_CH_Year3 	: 9.
      		Learners3		: 9. 
      		GPercentMale    : 8.
      	;
      
   RUN;

%MEND read_data;

/* Call the macro with the file path and output dataset name */
%read_data(file='/home/u64180336/CH_data/FE.csv', out=FE_College);

TITLE 'SIXTH FORM COLLEGE';
PROC PRINT DATA=CH_data.sixthFormCollege (OBS=10);
RUN;

TITLE 'FE METRICS';
PROC PRINT DATA=FE_Metrics (OBS=10); 
RUN;

TITLE 'FE COLLEGE';
PROC PRINT DATA=FE_College (OBS=10);
RUN;

/* *******************************2. CLEANING THE DATASETS************************************* */

TITLE 'Descriptive Statistics of SIXTH FORM COLLEGE';
PROC MEANS DATA=CH_data.sixthFormCollege MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

TITLE 'Descriptive Statistics of FE METRICS';
PROC MEANS DATA=FE_Metrics MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

TITLE 'Descriptive Statistics of FE COLLEGE';
PROC MEANS DATA=FE_College MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

/* Cleaning sixth form college dataset */
PROC SQL NOPRINT;
   SELECT MEAN(Total_CH_Year1), MEAN(Learners1), 
   		  MEAN(Total_CH_Year2), MEAN(Learners2), 
          MEAN(Total_CH_Year3), MEAN(Learners3)
   INTO :Mean_Total_CH_Year1, :Mean_Learners1, :Mean_Total_CH_Year2, :Mean_Learners2, 
   		:Mean_Total_CH_Year3, :Mean_Learners3
   FROM CH_data.sixthFormCollege;
QUIT;

PROC SQL;
	DELETE FROM CH_data.sixthFormCollege
	WHERE MISSING(Region);
	
	UPDATE CH_data.sixthFormCollege
	SET Total_CH_Year1	= COALESCE(Total_CH_Year1, &Mean_Total_CH_Year1),
		Learners1 		= COALESCE(Learners1,&Mean_Learners1 ),
		Total_CH_Year2 	= COALESCE(Total_CH_Year2, &Mean_Total_CH_Year2),
		Learners2 		= COALESCE(Learners2,&Mean_Learners2 ),
		Total_CH_Year3 	= COALESCE(Total_CH_Year3, &Mean_Total_CH_Year3),
		Learners3 		= COALESCE(Learners3,&Mean_Learners3 );
	
QUIT;

DATA CH_data.sixthFormCollege;
	SET CH_data.sixthFormCollege;
	GPercentMale = (100 - GPercentFemale);
	FORMAT GPercentFemale 8.;
	FORMAT GPercentMale 8.;
RUN;

/* Cleaning FE Metrics dataset */
PROC SQL NOPRINT;
   SELECT MEAN(GradPR), MEAN(VAF)
   INTO :mean_GradPR, :mean_VAF
   FROM FE_Metrics;
QUIT;

PROC SQL;
	DELETE FROM FE_Metrics
	WHERE MISSING(ID) AND MISSING(GradPR) AND MISSING(VAF);
	
	UPDATE FE_Metrics
	SET GradPR	= COALESCE(GradPR, &mean_GradPR),
		VAF 	= COALESCE(VAF,&mean_VAF );
QUIT;

PROC SQL NOPRINT;
   SELECT MEAN(Total_CH_Year1), MEAN(Learners1), 
   		  MEAN(Total_CH_Year2), MEAN(Learners2), 
          MEAN(Total_CH_Year3), MEAN(Learners3),
          MEAN(GPercentMale)
   INTO :Mean_Total_CH_Year1, :Mean_Learners1, :Mean_Total_CH_Year2, :Mean_Learners2, 
   		:Mean_Total_CH_Year3, :Mean_Learners3, :Mean_GPercentMale
   FROM FE_College;
QUIT;

/* Cleaning FE College dataset */
PROC SQL;
	DELETE FROM FE_College
	WHERE MISSING(InstitutionType) OR MISSING(Region);
	UPDATE FE_College
	SET Total_CH_Year1	= COALESCE(Total_CH_Year1, &Mean_Total_CH_Year1),
		Learners1 		= COALESCE(Learners1,&Mean_Learners1 ),
		Total_CH_Year2 	= COALESCE(Total_CH_Year2, &Mean_Total_CH_Year2),
		Learners2 		= COALESCE(Learners2,&Mean_Learners2 ),
		Total_CH_Year3 	= COALESCE(Total_CH_Year3, &Mean_Total_CH_Year3),
		Learners3 		= COALESCE(Learners3,&Mean_Learners3 ),
		GPercentMale	= COALESCE(GPercentMale, &Mean_GPercentMale);
	
QUIT;

DATA FE_College;
	SET FE_College;
	GPercentFemale = (100 - GPercentMale);
	FORMAT GPercentMale 8.;
	FORMAT GPercentFemale 8.;
RUN;

TITLE 'Descriptive Statistics of Cleaned SIXTH FORM COLLEGE';
PROC MEANS DATA=CH_data.sixthFormCollege MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

TITLE 'Descriptive Statistics of Cleaned FE METRICS';
PROC MEANS DATA=FE_Metrics MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

TITLE 'Descriptive Statistics of Cleaned FE COLLEGE';
PROC MEANS DATA=FE_College MEAN STD SKEWNESS KURTOSIS N NMISS;
RUN;

/* **************************3. MANIPULATING THE DATASETS ******************* */
/*  Join FE_College and FE_Metrics Datasets*/
PROC SQL;
   CREATE TABLE FE_Metrics_Data AS
   SELECT a.*, b.*
   FROM FE_College a
   INNER JOIN FE_Metrics b
   ON a.ID = b.ID;
QUIT;

/*  Append sixthFormCollege and FE_Metrics_Data Data Datasets*/
DATA Education_Institutions_Data;
   SET CH_data.sixthFormCollege FE_Metrics_Data;
   CH_per_Learner1 = Total_CH_Year1/Learners1;
   CH_per_Learner2 = Total_CH_Year2/Learners2;
   CH_per_Learner3 = Total_CH_Year3/Learners3;
   CH_per_Learner = (CH_per_Learner1 + CH_per_Learner2 + CH_per_Learner3)/3;
   
RUN;
/*  Arrange the order of columns and Drop the Columns that are not required for the analysis*/
DATA CH_data.Education_Institutions_Data;
	SET Education_Institutions_Data(DROP= Total_CH_Year1 Learners1 Total_CH_Year2 Learners2 Total_CH_Year3 Learners3 ID);
	RETAIN  GradPR VAF InstitutionType Region GPercentFemale GPercentMale
 			CH_per_Learner1	CH_per_Learner2	CH_per_Learner3	CH_per_Learner;
	
TITLE 'FE College with Metrics Data';
PROC PRINT DATA=FE_Metrics_Data (OBS=10);
RUN;

TITLE 'Education Institutions Data';
PROC PRINT DATA=CH_data.Education_Institutions_Data;
RUN;

TITLE 'Descriptive Statistics of Education Institutions Data';
PROC MEANS DATA=CH_data.Education_Institutions_Data MEAN STD SKEWNESS KURTOSIS N NMISS;
	var GPercentFemale GPercentMale GradPR VAF CH_per_Learner1 CH_per_Learner2 CH_per_Learner3
		CH_per_Learner;
RUN;

/* *********************4. SUMMARY OF THE DATASET**************************** */
PROC CONTENTS DATA=CH_data.Education_Institutions_Data;
RUN;

PROC UNIVARIATE DATA=CH_data.Education_Institutions_Data NOPRINT;
	VAR CH_per_Learner;
	HISTOGRAM / NORMAL;
	INSET MEAN MEDIAN STD MIN MAX / POSITION=NE;
RUN;

PROC UNIVARIATE DATA=CH_data.Education_Institutions_Data NOPRINT;
	VAR CH_per_Learner;
	OUTPUT OUT=quantile_values
		pctlpts=25 50 75 90 100
		pctlpre=Q_;
RUN;

data _null_;
	set quantile_values;
	call symputx("q25",Q_25);
	call symputx("q50",Q_50);
	call symputx("q75",Q_75);
	call symputx("q90",Q_90);
RUN;

DATA CH_data.Education_Institutions_Data;
	LENGTH InstitutionSize $15;
	SET CH_data.Education_Institutions_Data;
	IF CH_per_Learner > &q90 THEN InstitutionSize = "Large";
	ELSE IF &q75 <= CH_per_Learner < &q90 THEN InstitutionSize = "Large-Medium";
	ELSE IF &q50 <= CH_per_Learner < &q75 THEN InstitutionSize = "Medium";
	ELSE IF &q25 <= CH_per_Learner < &q50 THEN InstitutionSize = "Small-Medium";
	ELSE InstitutionSize = "Small";
	
RUN;

DATA CH_data.UK_Educational_Institutions_Data;
	RETAIN GradPR VAF InstitutionType Region GPercentFemale GPercentMale CH_per_Learner1 CH_per_Learner2
		   CH_per_Learner3	CH_per_Learner InstitutionSize;
	SET CH_data.Education_Institutions_Data;
RUN;

TITLE 'UK Educational Institutions Data';
PROC PRINT DATA=CH_data.UK_Educational_Institutions_Data;
RUN;

/* *************************4.STATISTICAL SUMMARY****************************** */

PROC TABULATE DATA = CH_data.UK_Educational_Institutions_Data;
	CLASS Region InstitutionType InstitutionSize;
	CLASSLEV Region / style=[background=yellow fontweight=bold];
	CLASSLEV InstitutionType / style=[background=lightgreen fontweight=bold];
	CLASSLEV InstitutionSize / style=[background=lightred fontweight=bold];
	var GradPR VAF GPercentFemale GPercentMale CH_per_Learner;
	
	table Region InstitutionType InstitutionSize, 
	( GradPR * (mean std skewness kurtosis)
	  VAF * (mean std skewness kurtosis)
	  GPercentFemale * (mean std skewness kurtosis)
	  GPercentMale * (mean std skewness kurtosis)
	  CH_per_Learner * (mean std skewness kurtosis)
	) / misstext = 'Missing';
	title ' Statistical summary of Region, InstitutionType, InstitutionSize Vs 
			GradPR, VAF, GPercentFemale, GPercentMale, CH_per_Learner';
RUN;


/* *********************5. EXPLORATORY DATA ANALYSIS************************* */
TITLE 'MATRIX PLOT TO FIND CORRELATION BETWEEN VARIABLES';
PROC SGSCATTER DATA=CH_data.UK_Educational_Institutions_Data;
	LABEL   GPercentFemale = 'GP_F'
			GPercentMale = 'GP_M'
			CH_per_Learner1 = 'CHL_1'
			CH_per_Learner2 = 'CHL_2'
			CH_per_Learner3 = 'CHL_3'
			CH_per_Learner = 'AVG_CH_L';
	MATRIX 	GradPR VAF GPercentFemale GPercentMale CH_per_Learner1 CH_per_Learner2 CH_per_Learner3 CH_per_Learner 	
			/ diagonal=(histogram);
RUN;

/* BOX PLOT - To find outliers for the variables in the dataset */

TITLE 'ANALYSIS OF OUTLIERS';
TITLE 'CH_per_learner VS Region';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX CH_per_Learner / CATEGORY=Region;
RUN;

TITLE 'CH_per_learner VS Institution Type';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX CH_per_Learner / CATEGORY=InstitutionType;
RUN;

TITLE 'CH_per_learner VS Institution Size';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX CH_per_Learner / CATEGORY=InstitutionSize;
RUN;

TITLE 'Male % VS Region';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GPercentMale / CATEGORY=Region;
RUN;

TITLE 'Male % VS Institution Type';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GPercentMale / CATEGORY=InstitutionType;
RUN;

TITLE 'Male % VS Institution Size';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GPercentMale / CATEGORY=InstitutionSize;
RUN;

TITLE 'VAF VS Region';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX VAF / CATEGORY=Region;
RUN;

TITLE 'VAF VS Institution Type';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX VAF / CATEGORY=InstitutionType;
RUN;

TITLE 'VAF VS Institution Size';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX VAF / CATEGORY=InstitutionSize;
RUN;

TITLE 'Graduation % VS Region';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GradPR / CATEGORY=Region;
RUN;

TITLE 'Graduation % VS Institution Type';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GradPR / CATEGORY=InstitutionType;
RUN;

TITLE 'Graduation % VS Institution Size';
PROC SGPLOT DATA=CH_data.UK_Educational_Institutions_Data;
	VBOX GradPR / CATEGORY=InstitutionSize;
RUN;

/* USE BOX-COX TO IDENTIFY THE TYPE OF TRANFORMATION TO BE USED TO REDUCE OUTLIERS */
TITLE 'BOX-COX ANALYSIS';                                                                          
PROC TRANSREG DATA=CH_data.UK_Educational_Institutions_Data;
	MODEL BOXCOX(CH_per_Learner) = IDENTITY(GradPR);
RUN;

/* TRANSFORMATION OF THE VARIABLES */
DATA Transformed_Data;
	SET CH_data.UK_Educational_Institutions_Data;
	Trans_CH_per_Learner = 1 / SQRT(CH_per_Learner);
RUN;

PROC STDIZE DATA=Transformed_Data OUT=standardized_data METHOD=STD;
	VAR Trans_CH_per_Learner;
RUN;

/* PROC PRINT DATA=Transformed_Data; */
/* RUN; */

TITLE 'SGPLOT FOR CH_per_Learner AFTER TRANFORMATION';
PROC SGPLOT DATA=standardized_data;
	VBOX Trans_CH_per_Learner / CATEGORY=Region;
RUN;

PROC SGPLOT DATA=standardized_data;
	VBOX Trans_CH_per_Learner / CATEGORY=InstitutionType;
RUN;

/* ***********************6.STATISTICAL MODELLING**************************** */
/* NPAR1WAY Wilcoxon & kruskal Wallis Analysis */
TITLE 'Statistical Modelling By Region - NPAR1WAY';
PROC NPAR1WAY DATA=CH_data.UK_Educational_Institutions_Data WILCOXON;
	CLASS Region;
	VAR GradPR VAF GPercentMale CH_per_Learner;
RUN;

TITLE 'Statistical Modelling By InstitutionType - NPAR1WAY';
PROC NPAR1WAY DATA=CH_data.UK_Educational_Institutions_Data WILCOXON;
	CLASS InstitutionType;
	VAR GradPR VAF GPercentMale CH_per_Learner;
RUN;

TITLE 'Statistical Modelling By InstitutionSize - NPAR1WAY';
PROC NPAR1WAY DATA=CH_data.UK_Educational_Institutions_Data WILCOXON;
	CLASS InstitutionSize;
	VAR GradPR VAF GPercentMale CH_per_Learner;
RUN;

/* Robust Regression Analysis */
TITLE 'Statistical Modelling - ROBUSTREG';
PROC ROBUSTREG DATA=CH_data.UK_Educational_Institutions_Data METHOD=M;
	CLASS Region InstitutionType InstitutionSize;
	MODEL CH_per_Learner = VAF GPercentMale GradPR;
	OUTPUT OUT=results R=residuals WEIGHT=weights;
RUN;

