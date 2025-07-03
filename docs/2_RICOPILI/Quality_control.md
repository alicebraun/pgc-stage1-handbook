
# **Quality control**

**Authors**: `<br>` Alice Braun, M.Sc., B.A. [braun@broadinstitute.org](mailto:braun@broadinstitute.org) `<br>`

## Standard filters

# PCA

```
prefix="dia_xxxxx_pop_ab-qc1"
PC1="0.5"  # pc1 cutoff
PC2="0.1"  # pc2 cutoff

cd pcaer_${prefix}

# exclude ancestry outlier IDs
awk -v pc1="$PC1" -v pc2="$PC2" '$4 > pc1 && $5 > pc2 {print $1, $2}' "${prefix}.menv.mds" > "${prefix}.pca1.ex"

# combine with related exclusions (if applicable) or run
plink --bfile "${prefix}" \
      --remove "${prefix}.pca1.ex" \
      --make-bed \
      --out "${prefix}.pca1.ex" \
      --allow-no-sex

```

## Outlier exclusion

```
# Extract both pairs of IDs (columns 1/2 and 3/4) to make exclusion list
cd pcaer_${prefix}

# Exclude all combinations of caco/coca overlap and related IDs
awk '{ split($1, a, "_"); split($3, b, "_"); if (a[1] != b[1]) print }' "${prefix}.mepr.overlap" > caco_coca.overlap

awk '{print $1, $2}' caco_coca.overlap > "${prefix}.overlap.ex"
awk '{print $3, $4}' caco_coca.overlap >> "${prefix}.overlap.ex"
awk '{print $1, $2}' "${prefix}.mepr.overlap" >> "${prefix}.overlap.ex"

# Count unique overlaps
sort "${prefix}.overlap.ex" | uniq | wc -l
# n of overlaps

# Combine with ancestry exclusion list
cat "${prefix}.pca1.ex" "${prefix}.overlap.ex" > "${prefix}.ids.ex"

# Run PLINK 1.9 to exclude individuals
plink \
  --bfile "${prefix}" \
  --remove "${prefix}.ids.ex" \
  --make-bed \
  --out "${prefix}.ex"
```
