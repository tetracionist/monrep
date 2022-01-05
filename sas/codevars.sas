%macro codevars(dsinput, dsoutput, vars, key, method=code, audit=work.audit, seed=5) ;

   %* make sure you save audit file to permenant storage ;
   %* you will need this to decode values afterwards ;

   %if &method = code %then %do ;
      %* assign a random number for each record based on the seed ;
      %* this will become our cipher ;
      data &dsoutput(drop=orig_: new_: rand cipher decipher)
           &audit(keep=&key rand cipher decipher orig_: new_:) ;
         set &dsinput ;
         rand   = round(ranuni(&seed),0.01) ;
         cipher = catx(' ', "*", rand) ;
         decipher = catx(' ', "/", rand) ;
      
         %* interact with space delimited list ;
         %* cipher the variables and store original and ciphered values in audit table ;  
         %do i = 1 %to %sysfunc(countw(&vars)) ;
            %let var = %scan(&vars, &i, %str( )) ;
            orig_&var = &var ;
            new_&var = &var * rand ;
            &var = new_&var ;
         %end ;
      
      run ;
   %end ;
   
   %else %if &method = decode %then %do ;
      data &dsoutput (drop=orig_: rand cipher decipher) ;
         merge &dsinput(in=a)
               &audit(in=b);
         by &key ;
         if a ;
         %* interact with space delimited list ;
         %* cipher the variables and store original and ciphered values in audit table ;  
         %do i = 1 %to %sysfunc(countw(&vars)) ;
            %let var = %scan(&vars, &i, %str( )) ;
            orig_&var = &var ;
            new_&var = divide(&var, rand) ;
            &var = new_&var ;
         %end ;
      run ;
    %end ;
 %mend ;
   
* example usage and testing  ;
/* 
options mprint ;   
%codevars(sashelp.cars, work.cars, EngineSize Length Weight, make model) ;
%codevars(work.cars, work.cars_un, EngineSize Length Weight, make model, method=decode) ;
   
proc compare base=sashelp.cars compare=cars_un ;
run ;  
*/