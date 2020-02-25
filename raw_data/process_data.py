import pandas as pd
df = pd.read_csv('PREF_cleaned_1999-2018_Underlying X, Multiple Opioid.tsv', sep='\t')
df = df.drop(labels="Notes", axis=1)

def rename_col(s):
    """Rename column to lower case and replace spaces with _"""
    return ("_").join(str.lower(s).split(" "))

df.rename(columns=rename_col, inplace=True)
print(df.head())

df.to_stata("opioid_death.dta", write_index=False)
