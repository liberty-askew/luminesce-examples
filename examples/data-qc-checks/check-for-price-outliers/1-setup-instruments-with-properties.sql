-- ============================================================
-- Description:
-- In this query we setup some equity instruments
-- NOTE: You'll need to have "Sector" setup as an instrument
-- property in LUSID and Luminesce as follows:
-- Instrument/ibor/Sector
-- ============================================================
-- Load data from CSV
@instruments_data =

use Drive.Excel
--file=/luminesce-examples/price_time_series.xlsx
--worksheet=instrument
enduse;

-- 1. Upload values for custom instrument properties
-- Transform data
@inst_properties =

select li.LusidInstrumentId as EntityId, 'LusidInstrumentId' as EntityIdType, 'Instrument' as Domain, 'ibor' as PropertyScope, a.
   PropertyCode, a.Value
from Lusid.Instrument li
inner join (
   select 'Sector' as PropertyCode, sector as Value, inst_id as EntityId
   from @instruments_data
   ) a
   on li.ClientInternal = a.EntityId;

--select * from @inst_properties;
-- Upload to Lusid.Property
select *
from Lusid.Property.Writer
where ToWrite = @inst_properties;

-- 2. Upload instrument equity data to inbuilt properties
-- Transform equity data
@equity_instruments =

select inst_id as ClientInternal, name as DisplayName, ccy as InferredDomCcy
from @instruments_data;

-- Upload to Lusid.Instrument.Equity
select *
from Lusid.Instrument.Equity.Writer
where ToWrite = @equity_instruments
   and DeletePropertiesWhereNull = True;
