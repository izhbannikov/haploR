#### haploR settings###

# LDlink settings
LD.settings <- list(ldmatrix.url="https://ldlink.nci.nih.gov/LDlinkRestWeb/ldmatrix", #"https://analysistools.nci.nih.gov/LDlink/LDlinkRest/ldmatrix",
                    ldmatrix.file.r2.url="https://ldlink.nci.nih.gov/tmp/r2_", #ldmatrix.file.r2.url="https://analysistools.nci.nih.gov/LDlink/tmp/r2_",
                    ldmatrix.file.dprime.url="https://ldlink.nci.nih.gov/tmp/d_prime_", # ldmatrix.file.dprime.url="https://analysistools.nci.nih.gov/LDlink/tmp/d_prime_"
                    avail.pop=c("YRI","LWK","GWD","MSL","ESN","ASW","ACB",
                                "MXL","PUR","CLM","PEL","CHB","JPT","CHS",
                                "CDX","KHV","CEU","TSI","FIN","GBR","IBS",
                                "GIH","PJL","BEB","STU","ITU",
                                "ALL", "AFR", "AMR", "EAS", "EUR", "SAS"),
                    avail.ld=c("r2", "d"))

# Haploreg settings
Haploreg.settings <- list(base.url="https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php",
                          extended.view.url="http://pubs.broadinstitute.org/mammals/haploreg/detail_v4.1.php?query=&id=",
                          study.url="http://pubs.broadinstitute.org/mammals/haploreg/haploreg.php")

# TODO - add other settings if needed


