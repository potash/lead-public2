drop table if exists output.tests;

create table output.tests as (
    select test_id, kid_id, 
        CASE WHEN a.address in 
            ('5001 S MICHIGAN AVE', '1634 W POLK ST', '810 W MONTROSE AVE') 
        THEN null ELSE a.address_id END AS address_id,
        apt, t.lab_id,
        bll, sample_date as date, 
        t.sample_type, 
        sample_date - k.date_of_birth AS age,
        first, first_bll6, first_bll10, increase, test_number,

        CASE WHEN l.count >= 50 THEN bll_percentiles[1] END as lod,
        CASE WHEN l.count >= 50 THEN 
            (bll_percentiles[1] != bll or bll_percentiles[1] = 1) END as detected
    
    from aux.tests t
    join aux.kid_tests_info kt using (test_id)
    left join aux.test_addresses ta using (test_id)
    left join aux.addresses a using (address_id)
    left join aux.kids k using (kid_id)
    left join output.lab_months l on
        l.lab_id = t.lab_id and
        l.month = date_trunc('month', sample_date) and
        l.sample_type = t.sample_type
);

create index on output.tests (kid_id, address_id);
