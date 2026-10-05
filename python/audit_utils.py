from __future__ import annotations
from pathlib import Path
import hashlib
import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.api as sm

CONSTRUCTS = {
    "PRA": [f"V{i}" for i in range(1, 8)],
    "MM": [f"V{i}" for i in range(8, 15)],
    "MA": [f"V{i}" for i in range(15, 22)],
    "MI": [f"V{i}" for i in range(22, 29)],
    "GFA": ["V29", "V30"],
}
COMPOSITE_MAP = {"PRA":"PRA_MEAN", "MM":"MM_MEAN", "MA":"MA_MEAN", "MI":"MI_MEAN", "GFA":"GFA_MEAN"}

def sha256(path: str | Path) -> str:
    h=hashlib.sha256()
    with open(path,'rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''): h.update(chunk)
    return h.hexdigest()

def read_xlsx(path: str | Path):
    raw = pd.read_excel(path, sheet_name="Raw_Data")
    codebook = pd.read_excel(path, sheet_name="Codebook")
    return raw, codebook

def validate_raw(df: pd.DataFrame) -> None:
    assert df.shape == (103, 30), df.shape
    assert list(df.columns) == [f"V{i}" for i in range(1, 31)]
    arr = df.to_numpy(dtype=float)
    assert np.isfinite(arr).all()
    assert ((arr >= 1) & (arr <= 5)).all()
    assert np.equal(arr, np.floor(arr)).all()

def score_constructs(df: pd.DataFrame) -> pd.DataFrame:
    validate_raw(df)
    return pd.DataFrame({k: df[v].astype(float).mean(axis=1) for k, v in CONSTRUCTS.items()})

def cronbach_alpha(df: pd.DataFrame) -> float:
    x = df.astype(float)
    k = x.shape[1]
    return float(k/(k-1) * (1 - x.var(ddof=1).sum() / x.sum(axis=1).var(ddof=1)))

def core_statistics(df: pd.DataFrame) -> pd.DataFrame:
    scores = score_constructs(df)
    rows=[]
    for k in CONSTRUCTS:
        rows += [("construct_mean",k,scores[k].mean()), ("construct_sd",k,scores[k].std(ddof=1)),
                 ("cronbach_alpha",k,cronbach_alpha(df[CONSTRUCTS[k]]))]
    rows.append(("cronbach_alpha","all_30_items",cronbach_alpha(df)))
    for k in ["PRA","MM","MA","MI"]:
        rp,pp=stats.pearsonr(scores[k],scores["GFA"])
        rs,ps=stats.spearmanr(scores[k],scores["GFA"])
        rows += [("pearson_r",k,rp),("pearson_p",k,pp),("spearman_rho",k,rs),("spearman_p",k,ps)]
    fit=sm.OLS(scores["GFA"], sm.add_constant(scores[["PRA","MM","MA","MI"]])).fit()
    for term,value in fit.params.items(): rows.append(("ols_b",term,value))
    for term,value in fit.pvalues.items(): rows.append(("ols_p",term,value))
    sy=scores["GFA"].std(ddof=1)
    for term in ["PRA","MM","MA","MI"]:
        rows.append(("ols_standardized_beta",term,fit.params[term]*scores[term].std(ddof=1)/sy))
    rows += [("model_r_squared","full",fit.rsquared),("model_adjusted_r_squared","full",fit.rsquared_adj),("model_f_p","full",fit.f_pvalue)]
    return pd.DataFrame(rows, columns=["metric","target","value"])

def compare_sav(xlsx_raw: pd.DataFrame, scores: pd.DataFrame, sav_path: str | Path) -> dict:
    try:
        import pyreadstat
    except ImportError as e:
        return {"available": False, "reason": str(e)}
    sav, meta = pyreadstat.read_sav(str(sav_path))
    raw_cols=[f"V{i}" for i in range(1,31)]
    missing=[c for c in raw_cols if c not in sav.columns]
    if missing: raise AssertionError(f"SAV missing raw items: {missing}")
    raw_diff=float(np.max(np.abs(sav[raw_cols].to_numpy(float)-xlsx_raw[raw_cols].to_numpy(float))))
    composites={}
    for k,v in COMPOSITE_MAP.items():
        if v in sav.columns:
            composites[k]=float(np.nanmax(np.abs(sav[v].to_numpy(float)-scores[k].to_numpy(float))))
    return {"available": True, "rows": len(sav), "variables": len(sav.columns), "raw_max_abs_difference": raw_diff,
            "composite_max_abs_difference": composites}
