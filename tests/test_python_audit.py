from pathlib import Path
import sys
import numpy as np
import pandas as pd
import pytest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'python'))
from audit_utils import read_xlsx, validate_raw, score_constructs, core_statistics, compare_sav

XLSX=ROOT/'data/original/Dataset_S1_Raw_Survey_Data.xlsx'
SAV=ROOT/'data/original/Dataset_S2_SPSS_Data_File.sav'
BENCH=ROOT/'data/reference/independent_python_benchmarks.csv'

def test_source_shape_and_range():
    raw, codebook=read_xlsx(XLSX); validate_raw(raw)
    assert codebook.shape[0] == 30
    assert list(codebook.iloc[:,0].astype(str)) == [f'V{i}' for i in range(1,31)]

def test_frozen_figshare_benchmarks():
    raw,_=read_xlsx(XLSX); actual=core_statistics(raw)
    expected=pd.read_csv(BENCH)
    merged=actual.merge(expected,on=['metric','target'],suffixes=('_actual','_expected'))
    assert len(merged) >= 40
    assert np.max(np.abs(merged.value_actual-merged.value_expected)) < 1e-9

def test_spss_raw_and_composite_consistency():
    raw,_=read_xlsx(XLSX); scores=score_constructs(raw); check=compare_sav(raw,scores,SAV)
    if check.get("available") is not True:
        pytest.skip("pyreadstat unavailable in this environment; GitHub Actions installs it")
    assert check['rows'] == 103
    assert check['raw_max_abs_difference'] == 0
    for value in check['composite_max_abs_difference'].values():
        assert value < 1e-10
