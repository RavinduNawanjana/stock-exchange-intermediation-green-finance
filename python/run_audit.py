from pathlib import Path
import json
import pandas as pd
from audit_utils import read_xlsx, validate_raw, score_constructs, core_statistics, compare_sav, sha256, CONSTRUCTS, cronbach_alpha

ROOT=Path(__file__).resolve().parents[1]
XLSX=ROOT/'data/original/Dataset_S1_Raw_Survey_Data.xlsx'
SAV=ROOT/'data/original/Dataset_S2_SPSS_Data_File.sav'
OUT=ROOT/'outputs/python'; OUT.mkdir(parents=True,exist_ok=True)
raw, codebook=read_xlsx(XLSX); validate_raw(raw); scores=score_constructs(raw)
assert codebook.shape[0] == 30
assert list(codebook.iloc[:,0].astype(str)) == [f'V{i}' for i in range(1,31)]

stats=core_statistics(raw)
stats.to_csv(OUT/'independent_statistics.csv',index=False)
scores.describe().T.to_csv(OUT/'construct_descriptives.csv')
pd.DataFrame([{"construct":k,"items":len(v),"cronbach_alpha":cronbach_alpha(raw[v])} for k,v in CONSTRUCTS.items()]).to_csv(OUT/'reliability.csv',index=False)

sav_check=compare_sav(raw,scores,SAV)
(OUT/'spss_reconciliation.json').write_text(json.dumps(sav_check,indent=2),encoding='utf-8')
summary={"xlsx_sha256":sha256(XLSX),"shape":list(raw.shape),"missing_cells":int(raw.isna().sum().sum()),"minimum":int(raw.min().min()),"maximum":int(raw.max().max()),"spss":sav_check}
(OUT/'audit_summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print(json.dumps(summary,indent=2))
print('Independent Python audit: PASS')
