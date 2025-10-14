---
output:
  html_document:
    df_print: paged
    keep_md: yes
  word_document: default
  pdf_document:
    fig_caption: yes
    includes:
    keep_tex: yes
    number_sections: no
title: "WHAM Model Comparison Figures"
header-includes:
  - \usepackage{longtable}
  - \usepackage{booktabs}
  - \usepackage{caption,graphics}
  - \usepackage{makecell}
  - \usepackage{lscape}
  - \renewcommand\figurename{Fig.}
  - \captionsetup{labelsep=period, singlelinecheck=false}
  - \newcommand{\changesize}[1]{\fontsize{#1pt}{#1pt}\selectfont}
  - \renewcommand{\arraystretch}{1.5}
  - \renewcommand\theadfont{}
---



##  {.tabset}


### SSB, F, R

<img src="./compare_SSB_F_R.png" style="display: block; margin: auto;" />


### CV

<img src="./compare_CV.png" style="display: block; margin: auto;" />


### Selectivity

<img src="./compare_sel_fleets.png" style="display: block; margin: auto;" /><img src="./compare_sel_indices.png" style="display: block; margin: auto;" /><img src="./compare_sel_tile.png" style="display: block; margin: auto;" />


### M

<img src="./compare_M_age4.png" style="display: block; margin: auto;" /><img src="./compare_M_tile.png" style="display: block; margin: auto;" />


### Reference Points

<img src="./compare_ref_pts.png" style="display: block; margin: auto;" /><img src="./compare_rel_status_kobe.png" style="display: block; margin: auto;" /><img src="./compare_rel_status_timeseries.png" style="display: block; margin: auto;" />

<!-- ##  Real tabs {.tabset}


<img src="./compare_CV.png" style="display: block; margin: auto;" /><img src="./compare_M_age4.png" style="display: block; margin: auto;" /><img src="./compare_M_tile.png" style="display: block; margin: auto;" /><img src="./compare_ref_pts.png" style="display: block; margin: auto;" /><img src="./compare_rel_status_kobe.png" style="display: block; margin: auto;" /><img src="./compare_rel_status_timeseries.png" style="display: block; margin: auto;" /><img src="./compare_sel_fleets.png" style="display: block; margin: auto;" /><img src="./compare_sel_indices.png" style="display: block; margin: auto;" /><img src="./compare_sel_tile.png" style="display: block; margin: auto;" /><img src="./compare_SSB_F_R.png" style="display: block; margin: auto;" />
 -->
