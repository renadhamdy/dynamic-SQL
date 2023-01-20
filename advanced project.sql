--select * from user_cons_columns
--lumnsselect * from all_constraints
--select * from user_constraints ;

--select constraint_name 
--from user_constraints u , user_tab_columns , user_cons_columns 
--where u.constraint_type ='P' and user_tab_columns.data_type='NUMBER' and  user_cons_columns.column_name =  USER_TAB_COLUMNS.COLUMN_NAME

--select * from user_tab_columns;
--select * from user_cons_columns;

declare 
cursor pk_con is 
select distinct c.table_name,c.column_name as c_name
FROM  user_constraints u , user_cons_columns c, user_tab_columns t
    WHERE  u.table_name = c.table_name AND U.CONSTRAINT_NAME = C.CONSTRAINT_NAME 
            and u.constraint_type ='P' and t.data_type ='NUMBER'
            and  C.COLUMN_NAME NOT IN  ('START_DATE', 'JOB_ID', 'COUNTRY_ID');


v_max_id number(8,4);



cursor seq_cursor is select sequence_name from user_sequences;


begin 
for seq_record in seq_cursor loop 

execute immediate 'drop sequence '||seq_record.sequence_name;
end loop; 


for table_record in pk_con loop 

                    EXECUTE IMMEDIATE ' SELECT (NVL(MAX( '||table_record.c_name||' ),0)+1) 
                    FROM HR.' || table_record.table_name
                    INTO v_max_id;
                    
                    
                 EXECUTE IMMEDIATE ' CREATE SEQUENCE '||table_record.table_name||'_SEQ
                START WITH '||v_max_id||'
                  MAXVALUE 99999999999
                  MINVALUE 1
                  NOCYCLE
                  CACHE 20
                  NOORDER';
                  
                Execute immediate'CREATE OR REPLACE TRIGGER '||table_record.table_name||'_tr
                BEFORE INSERT
                ON '||table_record.table_name||'
                FOR EACH ROW
                BEGIN
                  :new.'||table_record.c_name||' := '||table_record.table_name||'_SEQ.nextval;
                        END;';

                    
end loop; 

end;
















