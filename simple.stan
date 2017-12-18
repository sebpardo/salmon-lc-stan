// RStan model of simplified example in salmon life cycle workshop

data {
  int<lower=1> N;         // number of years/steps
  real<lower=0> s1;       // egg-to-smolt survival
  vector<lower=0>[N] s2;  // survival from smolt to pfa
  real<lower=0> s3;       // survival from pfa to return
  real<lower=0> propf;    // proportion female
  real<lower=0> fec;      // fecundity (4000)
  vector<lower=0>[N] h;   // harvest rate
  real<lower=0> cvdummy;  // cv
}

transformed data{
   real expcvdummy = cvdummy;  // cv
}

// this are the parameters for which we do sampling (i.e. assign priors)
parameters {
  vector<lower=0>[N] pfa;         // pre-fishery abundance per year
  vector<lower=0>[N] returns;     // returns per year
  vector<lower=0>[N] smolts;      // smolt production per year
}

// estimate additional parameters from sampled parameters (don't have priors)
transformed parameters {  
  vector<lower=0>[N] eggs;        // number of eggs per fish
  vector<lower=0>[N] spawners;    // number of spawners
  vector<lower=0>[N] catches;     // number of catches

  for (t in 1:N) {
    catches[t] = returns[t] * h[t];         
    spawners[t] = returns[t] * (1 - h[t]);    
    eggs[t] = spawners[t] * propf * fec;
  }  
}

// parameters declared here are not saved on output
model {
  vector[N] mulogsmolts;          // log smolt number
  vector[N] mulogreturns;         // log returns number
  vector[N] mulogpfa;             // log pfa
  vector[N] logsmolts;           // log smolt number
  vector[N] logreturns;          // log returns number
  vector[N] logpfa;              // log pfa
  
  for (t in 1:N) {
    logsmolts[t] = log(smolts[t]);
    logpfa[t] = log(pfa[t]);
    logreturns[t] = log(returns[t]);
    
    // these first two lines look strange but are Stan's version of if_else statements:
    mulogsmolts[t] = t == 1 ? log(s1 * 100000) : log(s1 * eggs[t-1]); // providing starting smolt values at t = 1, eggs0 = 100000
    mulogpfa[t] = t == 1 ? log(0.25 * 500) : log(s2[t-1] * smolts[t-1]); // providing starting pfa values at t = 1 
    mulogreturns[t] = log(s3 * pfa[t]);  // PFA -> returns with survival s3 fixed to 0.5
  }
  
  // lognormal distributions
  logsmolts  ~ normal(mulogsmolts, expcvdummy);
  logpfa  ~ normal(mulogpfa,  expcvdummy);
  logreturns ~ normal(mulogreturns, expcvdummy);
}

