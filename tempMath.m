clear all 
clc

pA_l = .7; pA_h = .9;
pB_l = .65; pB_h = .8;

w1_ll = (pA_l * ( pB_l))./(pA_l * pB_l + pA_l * (1 - pB_l) + (1 - pA_l) * pB_l);
w2_ll = (pA_l * (1 - pB_l))./(pA_l * pB_l + pA_l * (1 - pB_l) + (1 - pA_l) * pB_l);
w3_ll = ((1-pA_l) * ( pB_l))./(pA_l * pB_l + pA_l * (1 - pB_l) + (1 - pA_l) * pB_l);

[w1_ll, w2_ll, w3_ll]

w1_lh = (pA_l * ( pB_h))./(pA_l * pB_h + pA_l * (1 - pB_h) + (1 - pA_l) * pB_h);
w2_lh = (pA_l * (1 - pB_h))./(pA_l * pB_h + pA_l * (1 - pB_h) + (1 - pA_l) * pB_h);
w3_lh = ((1-pA_l) * ( pB_h))./(pA_l * pB_h + pA_l * (1 - pB_h) + (1 - pA_l) * pB_h);

[w1_lh, w2_lh, w3_lh]
