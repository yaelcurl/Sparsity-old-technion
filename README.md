Sparsity-based methods have long been used to approach the problem of noise removal from standard images.
This project tries to combine these methods together with fractal models
(based on fractional Brownian Motion) and implement on natural texture images, 
which involves fine details and stochastic behavior that requires different handling when aiming forwhite noise removal.
Also, applies these models to the separation task of an image which has both smooth geometryparts ('cartoon') and texture details.
Experiments were done on famous images as well as on images taken from texture databases (mcgill, vistex, ect.) using matlab,
with standard dictionaries (haarwavelet, DCT) and fBM based dictionary with different Hurst parameters. 
Results show that fBM dictionary does perform ok on stochastic texture images, however, 
removing high-STD white noise using sparsity methods is still a challenge. 
Separation was done by local dictionary-training algorithm, and achieved the texture layer with fBM initialization.
Open questions remain regarding the preservation of the statistics of fine texture details
in a method that is based on measuring the l2 error; 
the use of fBM atoms for sparse representation which are not well definedand are not even 'similar' by common tests
for the same H parameter; 
objective measures of image separation, separation offine details vs. 
rough texture andthe choice of crucialalgorithm's parameters.

External libraries:
- ksvdbox12 (Ron Rubinstein)
- Local_MCA_KSVD (Michael Elad matlab book package)
- Fraclab 
