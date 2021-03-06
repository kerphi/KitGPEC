CREATE VIEW view_skills_without_family AS
select c.skill_code,skill_shortname from skills c
where not exists (select null FROM family_skills fc where c.skill_code=fc.skill_code)
ORDER BY skill_code;


CREATE VIEW view_family_full_restriction AS
select distinct family_id from family_skills
 where family_id not in(
                        select distinct family_id from family_skills
                            where  discriminante='NON')
 ORDER BY family_id;

CREATE VIEW view_family_without_restriction AS
select distinct family_id from family_skills
 where family_id not in(
                        select distinct family_id from family_skills
                            where  discriminante='OUI')
 ORDER BY family_id;


CREATE VIEW  view_agents_family_without_rules AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule is null
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=2
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=table2.nb_comp_neccessaire
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2_discriminantes AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule = '4X2'
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=2
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=table2.nb_comp_neccessaire
ORDER BY family_id, agent_id;



CREATE VIEW  view_agents_family_4X2_discriminant AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_agents_family_4X2_discriminantes va on va.family_id=fc.family_id
where fc.skill_code=ac.skill_code
AND ac_level >=2
and va.agent_id=ac.agent_id
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=4
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2_without_discriminant AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_family_without_restriction vs on vs.family_id=fc.family_id ,family f
where ac_level >=2 and f.family_id = vs.family_id
and ac.skill_code=fc.skill_code and family_rule='4X2'
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=4
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2 AS
select * from view_agents_family_4X2_without_discriminant vs union (select * from view_agents_family_4X2_discriminant va) order by family_id,agent_id;



CREATE VIEW  view_agents_family_3X3_discriminantes AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule = '3X3'
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=3
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=table2.nb_comp_neccessaire
ORDER BY family_id, agent_id;



CREATE VIEW  view_agents_family_3X3_discriminant AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_agents_family_3X3_discriminantes va on va.family_id=fc.family_id
where fc.skill_code=ac.skill_code
AND ac_level >=3
and va.agent_id=ac.agent_id
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=3
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_3X3_without_discriminant AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_family_without_restriction vs on vs.family_id=fc.family_id ,family f
where ac_level >=3 and f.family_id = vs.family_id
and ac.skill_code=fc.skill_code and family_rule='3X3'
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=3
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_3X3 AS
select * from view_agents_family_3X3_without_discriminant vs union (select * from view_agents_family_3X3_discriminant va) order by family_id,agent_id;

--nombre agents par famille
CREATE VIEW view_nb_agents_family AS
select finalvue.family_id, nb_agent
from
(select family_id, count(agent_id) as nb_agent from view_agents_family_4X2 group by family_id UNION
    select family_id, count(agent_id) as nb_agent from view_agents_family_3X3 vaf group by family_id
    UNION select family_id, count(agent_id) as nb_agent from view_agents_family_without_rules group by family_id) as finalvue
group by finalvue.family_id,nb_agent
order by finalvue.family_id;


CREATE VIEW view_agents_family AS
select finalvue.family_id, agent_id
from
(select family_id, agent_id from view_agents_family_4X2 group by family_id,agent_id UNION
    select family_id, agent_id from view_agents_family_3X3 vaf group by family_id,agent_id
    UNION select family_id, agent_id from view_agents_family_without_rules group by family_id,agent_id)
     as finalvue
group by finalvue.family_id,agent_id
order by finalvue.family_id,agent_id;

CREATE VIEW view_agents_without_family AS
select distinct agent_id from agents
 where agent_id not in(select distinct agent_id from view_agents_family)
  ORDER BY agent_id;

CREATE VIEW view_nb_agents_without_family AS
select count(agent_id) from view_agents_without_family;

CREATE VIEW view_age_agents_family AS
select vaf.family_id, avg(AGE(agent_birthdate)) as moyenne_age,median(age(agent_birthdate)) AS median_age,moyenne_hors_CDD,median_hors_CDD
 from agents a , view_agents_family vaf left  join
                                           (select  vaf.family_id, avg(AGE(agent_birthdate)) as moyenne_hors_CDD,median(age(agent_birthdate)) AS median_hors_CDD
                                           from agents a , view_agents_family vaf
										   where 	a.agent_id= vaf.agent_id and agent_contrat not in ('CDD')  group by vaf.family_id
										   ) hors_CDD
										   on hors_CDD.family_id=vaf.family_id

  where 	a.agent_id= vaf.agent_id
  group by vaf.family_id,moyenne_hors_CDD,median_hors_CDD
    order by vaf.family_id ;


CREATE VIEW view_retirement_65 AS
 select vaf.family_id,count(date_part('year', (AGE(agent_birthdate)))+5) as nb_depart
 from agents a , view_agents_family vaf
 where 	a.agent_id = vaf.agent_id and a.agent_contrat not in ('CDD')
 and 	date_part('year', (AGE(agent_birthdate)))+5 >65
    group by vaf.family_id
    order by vaf.family_id ;


CREATE VIEW view_distribution_corps AS
select vaf.family_id,sum(CASE WHEN agent_contrat = 'CDD' THEN 1 ELSE 0 END) as nb_CDD,
sum(CASE WHEN agent_contrat = 'CDI' THEN 1 ELSE 0 END) as nb_CDI,
	sum(CASE WHEN agent_corps = 'IR' THEN 1 ELSE 0 END) as nb_IR,
    sum(CASE WHEN agent_corps = 'IE' THEN 1 ELSE 0 END) as nb_IE,
     sum(CASE WHEN agent_corps = 'AI' THEN 1 ELSE 0 END) as nb_AI,
    sum(CASE WHEN agent_corps = 'T' THEN 1 ELSE 0 END) as nb_T,
         sum(CASE WHEN agent_corps = 'ATR' THEN 1 ELSE 0 END) as nb_ATR
    from view_agents_family vaf,agents ag
where ag.agent_id = vaf.agent_id
group by vaf.family_id;



CREATE VIEW view_family_without_agents AS
select distinct family_id from family
 where family_id not in(select distinct family_id from view_agents_family)
  ORDER BY family_id;


-- Vue globale
 CREATE VIEW view_global AS
select vaf.family_id, a.agent_id,a.agent_birthdate, agent_contrat, a.agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level
from view_agents_family vaf, agents_skills ac,family_skills fc, skills c,agents a
LEFT JOIN  agents_organigramme ag ON ag.agent_id = a.agent_id
LEFT JOIN  agents_services ags ON ags.agent_id = a.agent_id
where ac.skill_code=fc.skill_code and c.skill_code = fc.skill_code and vaf.family_id=fc.family_id
and a.agent_id = ac.agent_id and a.agent_id=vaf.agent_id
group by vaf.family_id, a.agent_id,a.agent_birthdate, a.agent_contrat, a.agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level
order by vaf.family_id ;


CREATE VIEW view_distribution_service AS
select   vaf.family_id,
sum(CASE WHEN serv_code = 'APIL' THEN 1 ELSE 0 END) as APIL,
	sum(CASE WHEN serv_code = 'Communication' THEN 1 ELSE 0 END) as Communication,
    sum(CASE WHEN serv_code = 'Coordination' THEN 1 ELSE 0 END) as Coordination,
     sum(CASE WHEN serv_code = 'Direction' THEN 1 ELSE 0 END) as Direction,
    sum(CASE WHEN serv_code = 'DORE' THEN 1 ELSE 0 END) as DORE,
	sum(CASE WHEN serv_code = 'Edition numerique' THEN 1 ELSE 0 END) as Edition_numerique,
    sum(CASE WHEN serv_code = 'FDD' THEN 1 ELSE 0 END) as FDD,
     sum(CASE WHEN serv_code = 'Formation' THEN 1 ELSE 0 END) as Formation,
    sum(CASE WHEN serv_code = 'I Dev' THEN 1 ELSE 0 END) as I_DEV,
     sum(CASE WHEN serv_code = 'I Prod' THEN 1 ELSE 0 END) as I_PROD,
    sum(CASE WHEN serv_code like 'N%go' THEN 1 ELSE 0 END) as Nego,
	sum(CASE WHEN serv_code = 'Portails' THEN 1 ELSE 0 END) as Portails,
     sum(CASE WHEN serv_code = 'R et D' THEN 1 ELSE 0 END) as R_et_D,
    sum(CASE WHEN serv_code = 'SFJ' THEN 1 ELSE 0 END) as SFJ,
    sum(CASE WHEN serv_code = 'SIB' THEN 1 ELSE 0 END) as SIB,
    sum(CASE WHEN serv_code = 'SPP' THEN 1 ELSE 0 END) as SPP,
     sum(CASE WHEN serv_code = 'SRH' THEN 1 ELSE 0 END) as SRH,
    sum(CASE WHEN serv_code = 'STL' THEN 1 ELSE 0 END) as STL,
	sum(CASE WHEN serv_code = 'Termino' THEN 1 ELSE 0 END) as Termino,
    sum(CASE WHEN serv_code = 'Traduction' THEN 1 ELSE 0 END) as Traduction,
     sum(CASE WHEN serv_code = 'VBDD' THEN 1 ELSE 0 END) as VBDD,
    sum(CASE WHEN serv_code = 'Web' THEN 1 ELSE 0 END) as Web
    from view_agents_family vaf,agents ag, agents_services ase
where ag.agent_id = vaf.agent_id and ase.agent_id = ag.agent_id
group by vaf.family_id;


CREATE VIEW view_distribution_organigramme AS
select vaf.family_id,sum(CASE WHEN orga_code = 'DDO' THEN 1 ELSE 0 END) as DDO,
sum(CASE WHEN orga_code = 'DSI' THEN 1 ELSE 0 END) as DSI,
	sum(CASE WHEN orga_code = 'SGAL' THEN 1 ELSE 0 END) as SGAL,
    sum(CASE WHEN orga_code = 'DPI' THEN 1 ELSE 0 END) as DPI,
     sum(CASE WHEN orga_code = 'DOS' THEN 1 ELSE 0 END) as DOS,
    sum(CASE WHEN orga_code = 'Direction' THEN 1 ELSE 0 END) as Direction
    from view_agents_family vaf,agents ag, agents_organigramme ao
where ag.agent_id = vaf.agent_id and ao.agent_id = ag.agent_id
group by vaf.family_id;



CREATE VIEW view_distribution_skills_corps AS
select vaf.family_id, skill_shortname,
	sum(CASE WHEN agent_corps = 'IR' THEN 1 ELSE 0 END) as nb_IR,
    sum(CASE WHEN agent_corps = 'IE' THEN 1 ELSE 0 END) as nb_IE,
     sum(CASE WHEN agent_corps = 'AI' THEN 1 ELSE 0 END) as nb_AI,
    sum(CASE WHEN agent_corps = 'T' THEN 1 ELSE 0 END) as nb_T,
         sum(CASE WHEN agent_corps = 'ATR' THEN 1 ELSE 0 END) as nb_ATR
    from view_agents_family vaf,agents ag,family_skills fs,skills s, agents_skills ask
where ag.agent_id = vaf.agent_id and fs.skill_code=s.skill_code and fs.family_id=vaf.family_id
and ask.skill_code = s.skill_code and ask.agent_id = ag.agent_id
 and ask.ac_level>=1
group by vaf.family_id,skill_shortname;



CREATE VIEW view_distribution_skills_organigramme AS
select vaf.family_id, skill_shortname,
	sum(CASE WHEN orga_code = 'DDO' THEN 1 ELSE 0 END) as DDO,
sum(CASE WHEN orga_code = 'DSI' THEN 1 ELSE 0 END) as DSI,
	sum(CASE WHEN orga_code = 'SGAL' THEN 1 ELSE 0 END) as SGAL,
    sum(CASE WHEN orga_code = 'DPI' THEN 1 ELSE 0 END) as DPI,
     sum(CASE WHEN orga_code = 'DOS' THEN 1 ELSE 0 END) as DOS
    from view_agents_family vaf,agents ag,family_skills fs,skills s,agents_organigramme ao, agents_skills ask
where ag.agent_id = vaf.agent_id and fs.skill_code=s.skill_code and
fs.family_id=vaf.family_id and ao.agent_id = ag.agent_id
and ask.skill_code = s.skill_code and ask.agent_id = ag.agent_id
 and ask.ac_level>=1
group by vaf.family_id,skill_shortname;

CREATE VIEW view_distribution_skills_levels AS
select vaf.family_id, skill_shortname,
	sum(CASE WHEN ac_level in ( 1, 1.5 ) THEN 1 ELSE 0 END) as nb1,
sum(CASE WHEN ac_level in ( 2, 2.5 ) THEN 1 ELSE 0 END) as nb2,
	sum(CASE WHEN ac_level in ( 3, 3.5 ) THEN 1 ELSE 0 END) as nb3,
    sum(CASE WHEN ac_level in ( 4, 4.5 )THEN 1 ELSE 0 END) as nb4
    from view_agents_family vaf,agents ag,family_skills fs,skills s,agents_skills ags
where ag.agent_id = vaf.agent_id and fs.skill_code=s.skill_code and fs.family_id=vaf.family_id
and ags.agent_id = ag.agent_id and ags.skill_code = s.skill_code
group by vaf.family_id,skill_shortname;


CREATE VIEW view_incohesion_agent_family AS
select a.agent_id,a.family_id,skill_shortname,discriminante,ac_level
from agents a,family_skills fs , agents_skills ags, skills s
where a.agent_id = ags.agent_id and fs.skill_code=ags.skill_code
and s.skill_code = fs.skill_code
and a.family_id=fs.family_id
and a.agent_id not in (
						select a.agent_id
						from agents a
						LEFT JOIN  view_agents_family vaf ON a.agent_id =vaf.agent_id
						where a.family_id in(vaf.family_id))
order by a.agent_id;


CREATE VIEW view_percent_coherence AS
SELECT (1-cast(count(distinct( v.agent_id))
			/
            cast((SELECT count(a.agent_id) FROM agents a )as decimal)
        as decimal(3,2)))*100 as Pct_To_Total
from view_incohesion_agent_family v;


CREATE VIEW  view_agents_family_without_rules_discri_1 AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule is null
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=2
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=(table2.nb_comp_neccessaire-1)
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2_discriminantes_discri_1 AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule = '4X2'
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=2
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=(table2.nb_comp_neccessaire-1)
ORDER BY family_id, agent_id;



CREATE VIEW  view_agents_family_4X2_discriminant_discri_1 AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_agents_family_4X2_discriminantes_discri_1 va on va.family_id=fc.family_id
where fc.skill_code=ac.skill_code
AND ac_level >=2
and va.agent_id=ac.agent_id
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=3
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2_without_discriminant_discri_1 AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_family_without_restriction vs on vs.family_id=fc.family_id ,family f
where ac_level >=2 and f.family_id = vs.family_id
and ac.skill_code=fc.skill_code and family_rule='4X2'
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=3
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_4X2_discri_1 AS
select * from view_agents_family_4X2_without_discriminant_discri_1 vs union (select * from view_agents_family_4X2_discriminant_discri_1 va) order by family_id,agent_id;



CREATE VIEW  view_agents_family_3X3_discriminantes_discri_1 AS
select fc.family_id,agent_id, count(fc.skill_code) as nb_comp,table2.nb_comp_neccessaire
from agents_skills ac,family_skills fc inner join (
   				 select fc.family_id,count(skill_code) as nb_comp_neccessaire from family_skills fc,family f
				where discriminante='OUI' and fc.family_id=f.family_id and family_rule = '3X3'
                 group by fc.family_id order by fc.family_id) table2 on fc.family_id= table2.family_id
where fc.skill_code=ac.skill_code
AND discriminante='OUI' AND ac_level >=3
GROUP BY fc.family_id, agent_id,table2.nb_comp_neccessaire
HAVING count(fc.skill_code)>=(table2.nb_comp_neccessaire-1)
ORDER BY family_id, agent_id;



CREATE VIEW  view_agents_family_3X3_discriminant_discri_1 AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_agents_family_3X3_discriminantes_discri_1 va on va.family_id=fc.family_id
where fc.skill_code=ac.skill_code
AND ac_level >=3
and va.agent_id=ac.agent_id
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=2
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_3X3_without_discriminant_discri_1 AS
select fc.family_id,ac.agent_id, count(fc.skill_code) as nb_comp
from agents_skills ac,family_skills fc inner join view_family_without_restriction vs on vs.family_id=fc.family_id ,family f
where ac_level >=3 and f.family_id = vs.family_id
and ac.skill_code=fc.skill_code and family_rule='3X3'
GROUP BY fc.family_id, ac.agent_id
HAVING count(fc.skill_code)>=3
ORDER BY family_id, agent_id;

CREATE VIEW  view_agents_family_3X3_discri_1 AS
select * from view_agents_family_3X3_without_discriminant_discri_1 vs union (select * from view_agents_family_3X3_discriminant_discri_1 va) order by family_id,agent_id;


CREATE VIEW view_agents_family_discri_1 AS
select finalvue.family_id, agent_id
from
(select family_id, agent_id from view_agents_family_4X2_discri_1 group by family_id,agent_id UNION
    select family_id, agent_id from view_agents_family_3X3_discri_1 vaf group by family_id,agent_id
    UNION select family_id, agent_id from view_agents_family_without_rules_discri_1 group by family_id,agent_id)
     as finalvue
group by finalvue.family_id,agent_id
order by finalvue.family_id,agent_id;

CREATE VIEW view_nb_agents_family_discri_1  AS
select finalvue.family_id, nb_agent
from
(select family_id, count(agent_id) as nb_agent from view_agents_family_4X2_discri_1 group by family_id UNION
    select family_id, count(agent_id) as nb_agent from view_agents_family_3X3_discri_1 vaf group by family_id
    UNION select family_id, count(agent_id) as nb_agent from view_agents_family_without_rules_discri_1 group by family_id) as finalvue
group by finalvue.family_id,nb_agent
order by finalvue.family_id;



CREATE VIEW view_agents_family_level_1  AS
select fs.family_id, ac.agent_id
from family_skills fs, agents_skills ac inner join (
select fc.family_id,agent_id, count(skill_code) as nb_comp_neccessaire, table2.nb_comp
from family f, family_skills fc
inner join (select fs.family_id,ags.agent_id,count(fs.skill_code) as nb_comp
from view_agents_family_discri_1 vafd, agents_skills ags,family_skills fs
where vafd.agent_id = ags.agent_id and fs.skill_code=ags.skill_code and
fs.family_id = vafd.family_id and fs.discriminante ='OUI'
and ac_level >=1
group by fs.family_id,ags.agent_id)table2 on fc.family_id= table2.family_id
where discriminante='OUI' and fc.family_id=f.family_id and family_rule is null
    group by fc.family_id ,agent_id ,table2.nb_comp
   Having  table2.nb_comp>=count(skill_code)
    order by fc.family_id
 )table_level on ac.agent_id=table_level.agent_id
 where fs.skill_code = ac.skill_code and fs.family_id = table_level.family_id
 group by fs.family_id, ac.agent_id
;

CREATE VIEW view_nb_agents_family_level_1  AS
select family_id, count (DISTINCT agent_id) as nb_agent
from view_agents_family_level_1
group by family_id
order by family_id;

CREATE VIEW view_agent_proche_level_1  AS
select family_id,agent_id,'level_1' as proch from(
select vafl.family_id,vafl.agent_id from view_agents_family_level_1 vafl group by vafl.family_id,vafl.agent_id
EXCEPT
select vaf.family_id,vaf.agent_id from view_agents_family vaf
group by vaf.family_id,vaf.agent_id
) table_extrait
group by family_id,agent_id,proch
 order by family_id,agent_id ;

CREATE VIEW view_agent_proche_discri_1  AS
select family_id,agent_id,'discri_1' as proch from(
select vafl.family_id,vafl.agent_id from view_agents_family_discri_1 vafl group by vafl.family_id,vafl.agent_id
EXCEPT
select vaf.family_id,vaf.agent_id from view_agents_family vaf
group by vaf.family_id,vaf.agent_id
) table_extrait
group by family_id,agent_id,proch
 order by family_id,agent_id ;


CREATE VIEW view_agent_proche AS
select distinct vafd.family_id,vafd.agent_id,(CASE WHEN vafl.proch is null THEN 'discri_1' ELSE 'level_1' END) as proche
from view_agent_proche_discri_1 vafd
LEFT JOIN view_agent_proche_level_1 vafl on (vafd.family_id = vafl.family_id and vafd.agent_id=vafl.agent_id)
group by  vafd.family_id,vafd.agent_id,vafd.proch,proche ;

 CREATE VIEW view_global_proche AS
select * from (
select vaf.family_id, a.agent_id,a.agent_birthdate, agent_contrat, a.agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level,vaf.proche
from view_agent_proche vaf, agents_skills ac,family_skills fc, skills c,agents a
LEFT JOIN  agents_organigramme ag ON ag.agent_id = a.agent_id
LEFT JOIN  agents_services ags ON ags.agent_id = a.agent_id
where ac.skill_code=fc.skill_code and c.skill_code = fc.skill_code and vaf.family_id=fc.family_id
and a.agent_id = ac.agent_id and a.agent_id=vaf.agent_id
group by vaf.family_id, a.agent_id,a.agent_birthdate, a.agent_contrat, a.agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level,vaf.proche
Union
select family_id, agent_id,agent_birthdate, agent_contrat, agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level,'NON' as proche from view_global
group by family_id, agent_id,agent_birthdate,agent_contrat, agent_corps, orga_code,serv_code , discriminante,skill_shortname, ac_level,proche
) table_final
order by family_id, agent_id,discriminante,skill_shortname;




--test entitee

--insert into  agents VALUES (999,'1999-12-31','CDI','IR','DPI','TEST');

--insert into agents_skills VALUES ('c-se-gene-09',999,0);
--insert into agents_skills VALUES ('c-se-gene-17',999,0);
--insert into agents_skills VALUES ('c-s-logi-03',999,5);
--insert into agents_skills VALUES ('c-s-logi-07',999,5);
--insert into agents_skills VALUES ('c-s-logi-08',999,5);

-- Recherche agent,son niveau et nom competence par family_id et agent_id
--select agent_id,discriminante,ac_level,skill_shortname
--from agents_skills ac,family_skills fc, skills c
--where ac.skill_code=fc.skill_code and c.skill_code = fc.skill_code
--and agent_id in (41,110) and family_id='PROSP'
--group by discriminante,agent_id,ac_level,skill_shortname
--order by agent_id;