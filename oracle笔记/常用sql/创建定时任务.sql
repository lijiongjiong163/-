--����һ��dblink������ʽϵͳ����
create database link MDM_to_UAT
  connect to lijiongjiong identified by "ljj2019"
 using '(DESCRIPTION =(ADDRESS_LIST =(ADDRESS =(PROTOCOL = TCP)(HOST = 172.16.8.129)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = szqmdm)))';  
 --����һ�����¼��ʱ���񴥷�ʱ��
create table job_table(run_time date);

  --����ʵ��drop if exists ���ܵĴ洢����
  create or replace procedure proc_dropifexists(p_table in varchar2) is
  v_count number(10);
begin
  select count(*)
    into v_count
    from user_objects
   where object_name = upper(p_table);
  if v_count > 0 then
    execute immediate 'drop table ' || p_table || ' cascade constraints';
  end if;
end;
--�鿴����洢����
SELECT text FROM user_source WHERE NAME = upper('job_proc') ORDER BY line;

  --����һ���洢���̣�ִ����Ҫ���Ĳ�������������ʱ��д��job_table��
create or replace procedure job_proc is
begin
  --����drop_if_exists
  proc_dropifexists('mdm_everyday_job');
  --����
  execute immediate'
  create table mdm_everyday_job as(
    select t1.desc12, --���ϱ���
           t1.DESC48, --��������
           t1.DESC10, --��������״̬����
           t1.desc89, --��������״̬����
           t1.desc2 --������λ
      from szqmdm.mdm_wlzsh_code@mdm_to_uat t1, mdm_wlzsh_code t2
     where t1.desc12 = t2.desc12
       and (t1.desc2 != t2.desc2 or t1.desc48 != t2.desc48 or
           t1.desc10 != t2.desc10))';
  --ͣ������
  execute immediate'alter trigger update_mdm_wlzsh_code disable';
  --ˢ����
  update mdm_wlzsh_code a
     set a.desc48 =
         (select b.desc48 from mdm_everyday_job b where b.desc12 = a.desc12),
         a.desc10 =
         (select b.desc10 from mdm_everyday_job b where b.desc12 = a.desc12),
         a.desc2 =
         (select b.desc2 from mdm_everyday_job b where b.desc12 = a.desc12),
         a.desc89 =
         (select b.desc89 from mdm_everyday_job b where b.desc12 = a.desc12)
   where a.desc12 in (select DISTINCT desc12 from mdm_everyday_job);
  --����������
  execute immediate'alter trigger update_mdm_wlzsh_code enable';
  --��¼����ʱ��
  insert into job_table (run_time) values (sysdate);
  commit;
end;

--����һ����ʱjob
declare
  job number;
BEGIN
  DBMS_JOB.SUBMIT(JOB       => job, /*�Զ�����JOB_ID*/
                  WHAT      => 'job_proc;', /*��Ҫִ�еĴ洢�������ƻ�SQL���*/
                  NEXT_DATE => sysdate + 3 / (24 * 60), /*����ִ��ʱ��-��һ��3����*/
                  INTERVAL  => 'trunc(sysdate,''mi'')+1/(24*60)' /*ÿ��1����ִ��һ��*/);
  commit;
end;

--���ô���ʱ��Ϊÿ��Сʱһ��
begin dbms_job.interval(6, interval => 'trunc(sysdate,''mi'')+12/24'); end;
--�����´δ���ʱ��
begin
dbms_job.next_date(6,next_date => sysdate + 5 / 24 );
end;
--�鿴ִ�м�¼
select * from job_table
--�鿴�����ʱjob
select * from user_jobs;
--�����¼
delete from job_table
