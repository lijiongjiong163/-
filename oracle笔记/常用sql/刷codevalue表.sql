

--��ʼ
--1.����
create table MDM_ZQZT_0801 as
(
select desc12,DESC10,DESC89 from mdm_erpmnsx_3@to_Mdm_uat );
--drop table MDM_ZQZT_0801;
--select count(*) from MDM_ZQZT_0801;
commit;
--2.����ԭ������
create table wlzsh_back as (select *from mdm_wlzsh_code Where desc12  In (select Desc12 from MDM_ZQZT_0801 ));
--3.ͣ������
alter trigger update_mdm_wlzsh_code disable;
commit;
--4.ˢcode��
update mdm_wlzsh_code a
   set a.desc10 =
       (select b.desc10 from MDM_ZQZT_0801 b where b.desc12 = a.desc12),
    a.desc89 =
       (select b.desc89 from MDM_ZQZT_0801 b where b.desc12 = a.desc12)
 where a.desc12 in (select DISTINCT  desc12 from MDM_ZQZT_0801);
commit;
 --5.ˢdesc10
 update mdm_wlzsh_codeVALUE a
   set a.PROPERTYVALUE =
       (select b.DESC10 from mdm_wlzsh_code b where b.codeid = a.codeid)
 where a.codeid in
       (select d.codeid
  from (select c.codeid, b.PROPERTYVALUE, c.desc12, c.desc10
          from (select a.codeid, a.PROPERTYVALUE
                  from mdm_wlzsh_codeVALUE a
                 where a. PROPERTYCODE ='statusNumber') b
          left join mdm_wlzsh_code c
            on b.codeid = c.codeid) d
 where nvl(d.PROPERTYVALUE, 099) <> nvl(d.desc10, 099))
   and a.propertycode ='statusNumber';
  commit; 
--��(Ϊ0��ˢ�ɹ�)
select count(1)
  from (select c.codeid, b.PROPERTYVALUE, c.desc12, c.desc10
          from (select a.codeid, a.PROPERTYVALUE
                  from mdm_wlzsh_codeVALUE a
                 where a. PROPERTYCODE ='statusNumber') b
          left join mdm_wlzsh_code c
            on b.codeid = c.codeid) d
 where nvl(d.PROPERTYVALUE, 099) <> nvl(d.desc10, 099);
--6.ˢdesc89
 update mdm_wlzsh_codeVALUE a
   set a.PROPERTYVALUE =
       (select b.desc89 from mdm_wlzsh_code b where b.codeid = a.codeid)
 where a.codeid in
       (select d.codeid
  from (select c.codeid, b.PROPERTYVALUE, c.desc12, c.desc89
          from (select a.codeid, a.PROPERTYVALUE
                  from mdm_wlzsh_codeVALUE a
                 where a. PROPERTYCODE ='status') b
          left join mdm_wlzsh_code c
            on b.codeid = c.codeid) d
 where nvl(d.PROPERTYVALUE, 099) <> nvl(d.desc89, 099))
   and a.propertycode ='status';   
commit;   
--��(Ϊ0��ˢ�ɹ�)
select count(1)
  from (select c.codeid, b.PROPERTYVALUE, c.desc12, c.desc89
          from (select a.codeid, a.PROPERTYVALUE
                  from mdm_wlzsh_codeVALUE a
                 where a. PROPERTYCODE ='status') b
          left join mdm_wlzsh_code c
            on b.codeid = c.codeid) d
 where nvl(d.PROPERTYVALUE, 099) <> nvl(d.desc89, 099);

----7.������������ȫ����code��������
alter trigger update_mdm_wlzsh_code enable;
commit;


