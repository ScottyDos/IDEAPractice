CREATE OR REPLACE NONEDITIONABLE PROCEDURE GET_ONE_DAY_24_DATA(V_TIME in VARCHAR2)  --ʱ�䴫���ʽ  20150909
AS
    v_businessid VARCHAR(100);---ƽ̨ID
    v_resourceid VARCHAR(50);---���ݿ�ID
    v_businessname VARCHAR(200);---ƽ̨����
    v_resourcename VARCHAR(200);---���ݿ�ip

    v_taskid VARCHAR(50);

    v_starttime NUMBER;
    v_endtime NUMBER;

    v_where      CLOB;
    v_from_all    CLOB;
    v_where_all   CLOB;
    v_order_all   CLOB;
    v_sql_all     CLOB;

    --pragma  AUTONOMOUS_TRANSACTION;
BEGIN
--------------ʱ�����------------------
----�ж�
    IF V_TIME is null THEN
    --��������Ĭ��ȡǰһ������
    --ǰһ�� 00:00:00
    select get_millisecond(a) into v_starttime from (select to_date(a, 'YYYYMMDDHH24MISS') a from (select (to_char(sysdate-1,'YYYYMMDD')||'000000') a from dual));
    --ǰһ�� 23:59:59
    select get_millisecond(a) into v_endtime from (select to_date(a, 'YYYYMMDDHH24MISS') a from (select (to_char(sysdate-1,'YYYYMMDD')||'235959') a from dual));
    ELSE
    --������ȡ�����24Сʱ����
    --������ 00:00:00
    select get_millisecond(a) into v_starttime from (select to_date(a, 'YYYYMMDDHH24MISS') a from (select V_TIME||'000000' a from dual));
    --������ 23:59:59
    select get_millisecond(a) into v_endtime from (select to_date(a, 'YYYYMMDDHH24MISS') a from (select V_TIME||'235959' a from dual));
    --ɾ�����뵱�������
    delete from T_ORACLE_SESSION_H t where t.timeh >=v_starttime and t.timeh<=v_endtime;
    commit;
    END IF;

--------------����Ҫ�õ���SQL------------------
    v_from_all := '
      from TASK_TABLE               task, --���������--
      TASK_META_RELATION       task_meta, --���ڴ洢�����Ԫ����Ĺ�ϵ--
      META_TASK_TABLE          meta_task, --Ԫ�������ñ�
      RESOURCE_TABLE           res, --��Դ��--
      TASK_OPSCENARIO_RELATION task_opscenario, -- ������ά������ʵ����ϵ��
      OAS_OPSCENARIO           oas, --ά��������--
      OAS_OPSCENARIO_OPITEM    oas_opitem, --ά��������ά�����ϵ��--
      OAS_OPITEM               oas_op, --ά�����--
      OAS_OPSCENARIO_INST      oas_inst, --�����а�����ά������ʵ��--
      TASK_RESULT              task_res, --��������
      META_TASK_RESULT         meta_res, --Ԫ��������
      OAS_OPSCENARIO_RESULT    oas_res --ά������ִ�н����
    ';
    v_where_all :='
      where task.task_id = task_meta.task_id
      and task_meta.meta_task_id = meta_task.meta_task_id
      and res.resource_id = meta_task.resource_id
      and task_opscenario.task_id = task.task_id
      and task_opscenario.opsc_id = oas.id
      and oas.id = oas_opitem.opscenario_id
      and oas_opitem.opitem_id = oas_op.id
      and task_meta.opscenario_inst_id = oas_inst.id
      and oas_inst.opscenario_id = oas.id
      and task_res.task_id = task.task_id
      and meta_res.meta_task_id = meta_task.meta_task_id
      and meta_res.opitem_id = oas_op.id
      and meta_res.task_result_id = task_res.task_result_id
      and meta_res.opscenario_result_id = oas_res.id
      and oas_res.task_id = task.task_id
      and oas_res.task_result_id = task_res.task_result_id
      and oas_res.resource_id = res.resource_id
    ';
    v_order_all :='
      order by task.task_name
    ';
    --ѭ����ȡ��Դ�����û�õ���Դƴ��ȥsql��ѭ�������Ҫ������
    FOR RS IN (
      SELECT * FROM PLATFORM_HOST t where t.collect_type = 1 and t.database_type =1
    ) LOOP
    --����Դ��ֵ������
    v_businessid:=RS.BUSINESS_ID;
    v_resourceid :=RS.resource_id;
    v_businessname := RS.business_name;
    v_resourcename := RS.resource_name;

    v_taskid := '0f787c734970442895e2b6b0e302dd89';
  v_where:= v_where_all ||'
    and task_res.time >= '''||v_starttime ||'''
    and task_res.end_time <= '''|| v_endtime ||'''
    and task.business_id is not null
    and res.resource_name = '''||v_resourcename || '''
    and task.task_id = '''||v_taskid ||'''
    --and host.business_name ='''||v_businessname||'''
    --and meta_task.tem_name in(''��ǰ�Ự������'',''���Ự������'',''��ǰ�����Ự��'',''session������'',''��ǰ������'',''��������'',''Processesʹ����'')
  '||v_order_all;


  v_sql_all := 'insert into T_ORACLE_SESSION_H select ''' || v_businessid || '''bid,''' ||v_resourceid|| '''rid,c tmonth,
  a1,a2,a3,a4,a5,a6
  from
  (
  select c1,c,sum(to_number(a1)) a1,
  sum(to_number(a2)) a2,
  sum(to_number(a3)) a3,
  sum(to_number(a4)) a4,
  sum(to_number(a5)) a5,
  sum(to_number(a6)) a6
  from
  (
  select c1,c,decode(c2,''session������'',c3,0) a1,
  decode(c2,''���Ự������'',c3,0) a2,
  decode(c2,''��ǰ�Ự������'',c3,0) a3,
  decode(c2,''Processesʹ����'',c3,0) a4,
  decode(c2,''��ǰ������'',c3,0) a5,
  decode(c2,''��������'',c3,0) a6
  from
  (
   select task.task_name c1,to_char(get_date_from_millisecond(task_res.time),''yyyyMMddHH24'') c,meta_task.tem_name c2,meta_res.value c3'||v_from_all
  || v_where
  ||
  ')
  ) group by c1,c
  )
  '
  ;

  --insert into hisen(sql) values(v_sql_all);
  --dbms_output.put_line(v_sql_all);
  execute immediate v_sql_all;
  commit;

  END LOOP;
end GET_ONE_DAY_24_DATA;
/
