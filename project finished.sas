libname data '/home/u50265902/Myfolder/Project';

*Class_1 - Name Gender Age Height Weight Birthdate;
data class_1;
     set data.class_birthdate;
     format Birthdate date9.; *9=lenght of the format;
     Height=round(Height/39.37,0.01); 
     Weight=round(Weight/2.205,0.01);
run;

*Sort dataset class_1;
proc sort data=work.class_1;
	by name; 
run; 

*Class_2 - Name First Letter of Teacher;
data class_2;
     set data.class_teachers;
     keep Teacher Name;
     format Teacher $1.; *w=1, spaces shown;
run;

*Sort dataset class_2;
proc sort data=work.class_2;
	by name; 
run; 

*Class_3 - Name Quiz1-Quiz5;    
data class_3;
     set data.class_quiz;
run;

*Sort dataset class_3;
proc sort data=work.class_3;
	by name; 
run; 

*Merging all dataset;
data class;
     merge class_1 class_2 class_3;
     by Name;
run;


*Update results (using array);
data class_; 
	set class; 
	array add(*) quiz1-quiz5;
	if teacher="Thomas" then do;
		do i=1 to 5; 
			if (add(i) ne . ) then add(i)=add(i)+0.5; 
		end; 
	end;
	drop i;
run;
 
*Character variable Quiz_c1-Quiz_c5; 
proc format;
	*character;
	value $charqz	'4'='Not good at all' 
					'5'='Not very good' 
					'6'='Neither good nor bad'
					'7','8'='Fairly good' 
					'9','10'='Very good' 
					'11'='Excellent' 
					'.'='Absent'; 				
run;

data class_c;
	set work.class_;
	quiz_c1=put(quiz1,25. -L);
	quiz_c2=put(quiz2,25. -L);
	quiz_c3=put(quiz3,25. -L);
	quiz_c4=put(quiz4,25. -L);
	quiz_c5=put(quiz5,25. -L);
	format quiz_c1-quiz_c5 $charqz.;
run; 

*Lenght of char variables;
data class;
	set work.class_c;
	length quiz_c1 quiz_c2 quiz_c3 quiz_c4 quiz_c5 $25.;
run; 

*Report of 'Class' (with Title and Label);
ods pdf file="/folders/myfolders/students.pdf";
options nodate nonumber;
title "All students' quizzes results";
Proc report data=work.class 
	style(report)=[rules=groups frame=void]
	style(header)=[background=white font_face=arial font_weight= bold font_size=8pt];
	column  gender name age height weight birthdate teacher quiz1-quiz5 name quiz_c1-quiz_c5;
	define gender / order noprint;
	define HEIGHT /display"HEIGHT (Meters)";
	define weight /display "WEIGHT (Kilos)";
	
	compute before gender /style={font_face=arial font_size=8pt}; 
		line  "gender: "gender $1.;
	endcomp;
	compute after _page_ /style={font_face=arial font_size=6pt};
		line "Report group by gender";
	endcomp;
Run;
title;
ods pdf close; 
ods html;

*Mean of the quizzes for each student;
*Compute the mean excluding missing values;
data class_mean;
     set work.class;
     Mean_Quiz=mean(quiz1,quiz2,quiz3,quiz4,quiz5);
run;


*Table for Mean_Quiz;
proc means data=class_mean maxdec=2;
     class Gender;
     var Mean_Quiz;
     output out=Table;
run;

*RESULTS' COMMENTS: Females have better grades (mean F=7.82 mean M=7.48);


*Height divided in taller/smaller than the mean categories;
proc means data=class;
           var Height;
           output out=Mean_Height;
run;

*Add the column n_Height (Mean_Height=1.5833590=1.59);
data n_class;
     set class;
     length n_Height $25.;
     if Height>1.59 then n_Height="Taller than the mean";
     else n_Height="Smaller than the mean"; 
run;
     

*Two-way table Gender/n_Height;
proc freq data=n_class;
     table Gender*n_Height / list;
run;