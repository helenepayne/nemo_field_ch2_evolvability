
unit nf3_constants;

{$mode objfpc}{$H+}

interface

const r=5; {r=the max. number of traits}
      nvarcov = 15; {the number of (co)variances of a given type; r*(r+1)/2}
      maxnparm= 45; {the max. number of params}  {incl., Mat, Pat, k}
      emaxnparm=90; {the max. number of params incl lagrange multipliers}
      f=49;  {the max number of families}
      sibs=13; {max # of individuals in a family, including unmeasured}
      rhsibs=9;
      rfsibs=6; {max # of recip full sibs in a family}
      pos=65; {largest number of observations in a family (=< r*sibs)}
      nmax=589; {maximum total # of individuals in the dataset, including
                 those missing data}
      missing=-98; {Value in the dataset indicating missing phenotypic data}
      epsilon = 0.001;  {Convergence criterion}
      maxround=20;
      nf = 1;  {the max. number of fixed effects}
      p = 5;  {the maximum number of levels of fixed effects=r~nlevels}
      ceo = 4; {common environment option..4 for c.e, 1 for dominance}
      nconstr = 45; {maximum number of constraint equations to keep track of}

implementation

end.
