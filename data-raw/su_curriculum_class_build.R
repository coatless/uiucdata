# install.packages(c("readxl", "dplyr"))
# devtools::install_github("coatless/balamuta")

library("readxl")
library("dplyr")

## Refactor this at a later time.

### WARNING Summer 2010 data was edited! (Manually download for now)
# sapply(balamuta::pad_number(5:16), function(x) {
#   download.file(paste0("http://www.dmi.illinois.edu/stuenr/class/enrsu",x,".xls"),
#                 paste0("data-raw/su-enrollment/enrsu",x,".xls"))
# })

paths = dir("data-raw/su-enrollment", pattern = "\\.xls$", full.names = TRUE)
names(paths) = basename(paths)
enrollment_master = do.call(rbind, lapply(paths, read_excel, skip = 4))

colnames(enrollment_master) = c("term_code",
                                "college",
                                "department",
                                "degree",
                                "major_code",
                                "major_name",
                                "concentration_code",
                                "concentration_name",
                                "freshman",
                                "sophomore",
                                "junior",
                                "senior",
                                "nondegree_undergrad",
                                "total_undergrad",
                                "grad_master",
                                "grad_doctoral",
                                "nondegree_grad",
                                "total_grad",
                                "professional",
                                "overall_total",
                                "academic_program_code")

# Add a year column
enrollment_master$year = paste0("20", gsub(".*([0-9]{2}).*\\.xls.*", "\\1", rownames(enrollment_master)))

# Indicate it is in the Summer term
enrollment_master$term = factor("Summer", levels = c("Fall", "Spring", "Summer"))

rownames(enrollment_master) = seq_len(nrow(enrollment_master))

# Remove the summary tables
enrollment_master <- enrollment_master %>%
  filter(!is.na(term_code), !is.na(department))

# Force to factor
enrollment_master[,c(1:8, 21:22)] =
  lapply(enrollment_master[,c(1:8, 21:22)], FUN = factor)

summer_enrolled_ranking = as.data.frame(enrollment_master)

# Write externally for speed-up on second use
devtools::use_data(summer_enrolled_ranking, overwrite = TRUE)


